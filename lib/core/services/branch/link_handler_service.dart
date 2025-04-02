import 'dart:async';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/routes/go_router_config.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/providers/link_provider.dart';

class LinkHandlerService {
  static final LinkHandlerService instance = LinkHandlerService._();
  LinkHandlerService._();

  StreamSubscription<Map>? _branchSubscription;
  final Map<String, String> _branchParams = {};
  Map<dynamic, dynamic>? _pendingBranchData;
  Uri? _pendingDeepLinkUri;
  bool _isProcessingDeepLink = false;

  Future<void> initialize() async {
    try {
      _branchSubscription = FlutterBranchSdk.listSession().listen(
        (data) => _handleDeepLinkData(data),
        onError: (error) {},
      );

      await _checkInitialReferringData();
    } catch (e) {
      print('Error initializing LinkHandlerService: $e');
    }
  }

  Future<void> _checkInitialReferringData() async {
    try {
      final initialParams = await FlutterBranchSdk.getFirstReferringParams();
      if (initialParams.isNotEmpty) {
        _handleDeepLinkData(initialParams);
      }

      await FlutterBranchSdk.getLatestReferringParams();
    } catch (e) {
      // Error handling
    }
  }

  void _handleDeepLinkData(Map<dynamic, dynamic> data) {
    if (_isProcessingDeepLink) {
      return;
    }

    try {
      _isProcessingDeepLink = true;

      _pendingBranchData = data;
      _extractAndSaveCustomData(data);

      String? linkPath;
      String? fullUrl;

      if (data.containsKey('\$deeplink_path')) {
        linkPath = data['\$deeplink_path'] as String?;
      }

      if (data.containsKey('~referring_link')) {
        fullUrl = data['~referring_link'] as String?;
      }

      final linkProvider = LinkProvider.instance;
      if (linkPath != null) {
        linkProvider.setPendingDeepLink(linkPath);
      } else if (fullUrl != null) {
        linkProvider.setPendingDeepLink(fullUrl);
      }

      bool isAuthenticated = false;
      try {
        final auth0Provider = Auth0Provider.instance;
        isAuthenticated = auth0Provider.credentials != null;
      } catch (e) {
        isAuthenticated = false;
      }

      if (!isAuthenticated) {
        _isProcessingDeepLink = false;
        return;
      }

      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        if (linkPath != null) {
          _navigateBasedOnPath(linkPath);
        }
      } else if (fullUrl != null) {
        final Uri uri = Uri.parse(fullUrl);
        _handleDeepLink(uri);
      }
    } catch (e) {
      // Error handling
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  void _handleDeepLink(Uri uri) {
    bool isAuthenticated = false;
    try {
      final auth0Provider = Auth0Provider.instance;
      isAuthenticated = auth0Provider.credentials != null;
    } catch (e) {
      isAuthenticated = false;
    }

    final linkProvider = LinkProvider.instance;

    if (!isAuthenticated) {
      _pendingDeepLinkUri = uri;
      linkProvider.setPendingDeepLink(uri.toString());
      return;
    }

    final path =
        uri.path.isNotEmpty ? uri.path : uri.toString().split('://').last;

    if (path.startsWith('budgets/id=')) {
      final budgetId = path.substring('budgets/id='.length);
      _navigateToBudget(budgetId);
    } else if (path.startsWith('budgets') &&
        uri.queryParameters.containsKey('id')) {
      final budgetId = uri.queryParameters['id']!;
      _navigateToBudget(budgetId);
    } else if (path.startsWith('transactions/id=')) {
      final transactionId = path.substring('transactions/id='.length);
      _navigateToTransaction(transactionId);
    } else if (path.startsWith('transactions') &&
        uri.queryParameters.containsKey('id')) {
      final transactionId = uri.queryParameters['id']!;
      _navigateToTransaction(transactionId);
    } else if (path.startsWith('accounts/id=')) {
      final accountId = path.substring('accounts/id='.length);
      _navigateToAccount(accountId);
    } else if (path.startsWith('accounts') &&
        uri.queryParameters.containsKey('id')) {
      final accountId = uri.queryParameters['id']!;
      _navigateToAccount(accountId);
    } else if (path.startsWith('stats/')) {
      final statsPath = path.substring('stats/'.length);
      _navigateToStats(statsPath, uri.queryParameters);
    } else if (path == 'stats') {
      _navigateToStats('', uri.queryParameters);
    } else {
      _navigateBasedOnPath(path.split('/').first);
    }
  }

  void processPendingDeepLinks() {
    if (_isProcessingDeepLink) {
      Future.delayed(Duration(milliseconds: 500), () {
        processPendingDeepLinks();
      });
      return;
    }

    _isProcessingDeepLink = true;

    try {
      final linkProvider = LinkProvider.instance;
      final pendingLink = linkProvider.pendingDeepLink;

      if (pendingLink != null) {
        linkProvider.clearPendingDeepLink();

        if (_pendingBranchData != null) {
          if (_pendingBranchData!.containsKey('+clicked_branch_link') &&
              _pendingBranchData!['+clicked_branch_link'] == true) {
            final String? linkPath =
                _pendingBranchData!['\$deeplink_path'] as String?;
            if (linkPath != null) {
              _navigateBasedOnPath(linkPath);
            }
          } else {
            final String? url =
                _pendingBranchData!['~referring_link'] as String?;
            if (url != null) {
              final Uri uri = Uri.parse(url);
              _handleDeepLink(uri);
            } else {
              _navigateBasedOnPath(pendingLink);
            }
          }

          _pendingBranchData = null;
        } else if (_pendingDeepLinkUri != null) {
          _handleDeepLink(_pendingDeepLinkUri!);
          _pendingDeepLinkUri = null;
        } else {
          try {
            final uri = Uri.parse(pendingLink);
            _handleDeepLink(uri);
          } catch (e) {
            _navigateBasedOnPath(pendingLink);
          }
        }
      }
    } catch (e) {
      // Error handling
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  void _navigateToBudget(String budgetId) {
    BudgetServive.instance.getBudgetById(budgetId).first.then((budget) {
      if (budget != null) {
        goRouter.go(AppRoutes.budget(budgetId, budget: budget));
      } else {
        goRouter.go(AppRoutes.budgets());
      }
    }).catchError((error) {
      goRouter.go(AppRoutes.budgets());
    });
  }

  void _navigateToTransaction(String transactionId) {
    TransactionService.instance
        .getTransactionById(transactionId)
        .first
        .then((transaction) {
      if (transaction != null) {
        goRouter
            .go(AppRoutes.transaction(transactionId, transaction: transaction));
      } else {
        goRouter.go(AppRoutes.transactions());
      }
    }).catchError((error) {
      goRouter.go(AppRoutes.transactions());
    });
  }

  void _navigateToAccount(String accountId) {
    AccountService.instance.getAccountById(accountId).first.then((account) {
      if (account != null) {
        goRouter.go(AppRoutes.account(accountId, account: account));
      } else {
        goRouter.go(AppRoutes.accounts());
      }
    }).catchError((error) {
      goRouter.go(AppRoutes.accounts());
    });
  }

  void _extractAndSaveCustomData(Map<dynamic, dynamic> data) {
    try {
      if (data.containsKey('custom_data') && data['custom_data'] is Map) {
        final customData = data['custom_data'] as Map;
        _branchParams.clear();

        for (final entry in customData.entries) {
          _branchParams[entry.key.toString()] = entry.value.toString();
        }
      }
    } catch (e) {
      // Error handling
    }
  }

  void _navigateBasedOnPath(String path) {
    try {
      switch (path) {
        case 'subscription':
          goRouter.go('/subscription');
          break;
        case 'accounts':
          final accountId = _branchParams['id'];
          if (accountId != null) {
            _navigateToAccount(accountId);
          } else {
            goRouter.go(AppRoutes.accounts());
          }
          break;
        case 'transactions':
          final transactionId = _branchParams['id'];
          if (transactionId != null) {
            _navigateToTransaction(transactionId);
          } else {
            goRouter.go(AppRoutes.transactions());
          }
          break;
        case 'budgets':
          final budgetId = _branchParams['id'];
          if (budgetId != null) {
            _navigateToBudget(budgetId);
          } else {
            goRouter.go(AppRoutes.budgets());
          }
          break;
        default:
          goRouter.go('/');
          break;
      }
    } catch (e) {
      goRouter.go('/');
    }
  }

  Future<void> handleDeepLink(String url) async {
    try {
      if (_isProcessingDeepLink) {
        return;
      }

      _isProcessingDeepLink = true;

      final uri = Uri.parse(url);

      final linkProvider = LinkProvider.instance;
      linkProvider.setPendingDeepLink(url);

      bool isAuthenticated = false;
      try {
        final auth0Provider = Auth0Provider.instance;
        isAuthenticated = auth0Provider.credentials != null;
      } catch (e) {
        isAuthenticated = false;
      }

      if (!isAuthenticated) {
        _pendingDeepLinkUri = uri;
        _isProcessingDeepLink = false;
        return;
      }

      _handleDeepLink(uri);
      FlutterBranchSdk.handleDeepLink(url);
    } catch (e) {
      // Error handling
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  void _navigateToStats(String path, Map<String, String> params) {
    try {
      final filters = TransactionFilters(
        minDate: params['minDate'] != null
            ? DateTime.parse(params['minDate']!)
            : null,
        maxDate: params['maxDate'] != null
            ? DateTime.parse(params['maxDate']!)
            : null,
        categories: params['categories']?.split(','),
        accountsIDs: params['accounts']?.split(','),
        tagsIDs: params['tags']?.split(','),
        searchValue: params['search'],
      );

      switch (path) {
        case 'category':
          goRouter.go(AppRoutes.statsCategory('', filters: filters));
          break;
        case 'subcategory':
          goRouter.go('/stats/subcategory', extra: filters);
          break;
        case 'cash-flow':
          goRouter.go('/stats/cash-flow', extra: filters);
          break;
        case 'financial-health':
          goRouter.go('/stats/financial-health', extra: filters);
          break;
        case 'balance-evolution':
          goRouter.go('/stats/balance-evolution', extra: filters);
          break;
        default:
          goRouter.go('/stats', extra: filters);
          break;
      }
    } catch (e) {
      goRouter.go('/stats');
    }
  }

  Future<void> dispose() async {
    await _branchSubscription?.cancel();
    _branchSubscription = null;
    _branchParams.clear();
    _pendingBranchData = null;
    _pendingDeepLinkUri = null;
    _isProcessingDeepLink = false;
  }
}
