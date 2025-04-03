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
  bool _isProcessingDeepLink = false;

  Future<void> initialize() async {
    try {
      _branchSubscription = FlutterBranchSdk.listSession().listen(
        (data) => _handleDeepLinkData(data),
        onError: (error) {
          print('Branch SDK stream error: $error');
        },
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
      print('Error checking initial referring data: $e');
    }
  }

  void _handleDeepLinkData(Map<dynamic, dynamic> data) {
    if (_isProcessingDeepLink || data.isEmpty) {
      return;
    }

    try {
      _isProcessingDeepLink = true;
      _extractAndSaveCustomData(data);
      _processIncomingLink(data);
    } catch (e) {
      print('Error in _handleDeepLinkData: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  void _processIncomingLink(dynamic linkData) {
    bool isAuthenticated = false;
    try {
      final auth0Provider = Auth0Provider.instance;
      isAuthenticated = auth0Provider.credentials != null;
    } catch (e) {
      isAuthenticated = false;
      print('Auth check failed during link processing: $e');
    }

    final linkProvider = LinkProvider.instance;

    if (!isAuthenticated) {
      if (linkData is Map) {
        linkProvider.setPendingBranchData(linkData);
      } else if (linkData is Uri) {
        linkProvider.setPendingUri(linkData);
      } else {
        print('Error: Unknown link data type in _processIncomingLink');
      }
      return;
    }

    if (linkData is Map) {
      String? linkPath;
      String? fullUrl;

      if (linkData.containsKey('\$deeplink_path')) {
        linkPath = linkData['\$deeplink_path'] as String?;
      }

      if (linkData.containsKey('~referring_link')) {
        fullUrl = linkData['~referring_link'] as String?;
      }

      if (linkData.containsKey('+clicked_branch_link') &&
          linkData['+clicked_branch_link'] == true) {
        if (linkPath != null) {
          _navigateBasedOnPath(linkPath);
        } else if (fullUrl != null) {
          try {
            final Uri uri = Uri.parse(fullUrl);
            _handleDeepLinkUri(uri);
          } catch (e) {
            print(
                'Error parsing Branch referring link URL: $fullUrl, Error: $e');
            goRouter.go('/');
          }
        } else {
          print('Branch link clicked but no path or URL found.');
          goRouter.go('/');
        }
      } else if (fullUrl != null) {
        try {
          final Uri uri = Uri.parse(fullUrl);
          _handleDeepLinkUri(uri);
        } catch (e) {
          print(
              'Error parsing Branch referring link URL (non-click): $fullUrl, Error: $e');
          goRouter.go('/');
        }
      } else {
        print('Could not determine navigation from Branch data: $linkData');
        goRouter.go('/');
      }
    } else if (linkData is Uri) {
      _handleDeepLinkUri(linkData);
    } else {
      print('Error: Unknown link data type reached authenticated processing');
      goRouter.go('/');
    }
  }

  void _handleDeepLinkUri(Uri uri) {
    try {
      final path =
          uri.path.isNotEmpty ? uri.path : uri.toString().split('://').last;
      final queryParams = uri.queryParameters;

      List<String> pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty && uri.hasAuthority) {
        pathSegments = [uri.authority];
      } else if (pathSegments.isEmpty && path.isNotEmpty) {
        pathSegments = path.split('/');
      }

      if (pathSegments.isNotEmpty) {
        final String primaryPath = pathSegments.first.toLowerCase();
        String? id;

        if (pathSegments.length > 1) {
          id = pathSegments[1];
        }

        if (queryParams.containsKey('id')) {
          id = queryParams['id'];
        }

        switch (primaryPath) {
          case 'budgets':
            if (id != null) {
              _navigateToBudget(id);
            } else {
              goRouter.go(AppRoutes.budgets());
            }
            break;
          case 'transactions':
            if (id != null) {
              _navigateToTransaction(id);
            } else {
              goRouter.go(AppRoutes.transactions());
            }
            break;
          case 'accounts':
            if (id != null) {
              _navigateToAccount(id);
            } else {
              goRouter.go(AppRoutes.accounts());
            }
            break;
          case 'stats':
            String subPath = pathSegments.length > 1
                ? pathSegments.sublist(1).join('/')
                : '';
            _navigateToStats(subPath, queryParams);
            break;
          case 'subscription':
            goRouter.go('/subscription');
            break;
          default:
            print('Unhandled deep link path: $path');
            goRouter.go('/');
            break;
        }
      } else {
        print('Could not parse path from URI: $uri');
        goRouter.go('/');
      }
    } catch (e) {
      print('Error handling deep link URI $uri: $e');
      goRouter.go('/');
    }
  }

  void processPendingDeepLinks() {
    if (_isProcessingDeepLink) {
      Future.delayed(Duration(milliseconds: 300), processPendingDeepLinks);
      return;
    }

    _isProcessingDeepLink = true;

    try {
      final linkProvider = LinkProvider.instance;
      final pendingData = linkProvider.pendingBranchData;
      final pendingUri = linkProvider.pendingUri;

      if (pendingData != null) {
        print('Processing pending Branch data...');
        linkProvider.clearPendingLinks();
        _extractAndSaveCustomData(pendingData);
        _processIncomingLink(pendingData);
      } else if (pendingUri != null) {
        print('Processing pending URI...');
        linkProvider.clearPendingLinks();
        _processIncomingLink(pendingUri);
      }
    } catch (e) {
      print('Error processing pending deep links: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  void _navigateToBudget(String budgetId) {
    BudgetServive.instance.getBudgetById(budgetId).first.then((budget) {
      if (budget != null) {
        goRouter.go(AppRoutes.budget(budgetId, budget: budget));
      } else {
        print('Budget with ID $budgetId not found, navigating to list.');
        goRouter.go(AppRoutes.budgets());
      }
    }).catchError((error) {
      print('Error fetching budget $budgetId: $error');
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
        print(
            'Transaction with ID $transactionId not found, navigating to list.');
        goRouter.go(AppRoutes.transactions());
      }
    }).catchError((error) {
      print('Error fetching transaction $transactionId: $error');
      goRouter.go(AppRoutes.transactions());
    });
  }

  void _navigateToAccount(String accountId) {
    AccountService.instance.getAccountById(accountId).first.then((account) {
      if (account != null) {
        goRouter.go(AppRoutes.account(accountId, account: account));
      } else {
        print('Account with ID $accountId not found, navigating to list.');
        goRouter.go(AppRoutes.accounts());
      }
    }).catchError((error) {
      print('Error fetching account $accountId: $error');
      goRouter.go(AppRoutes.accounts());
    });
  }

  void _extractAndSaveCustomData(Map<dynamic, dynamic> data) {
    try {
      _branchParams.clear();
      if (data.containsKey('custom_data')) {
        final customData = data['custom_data'];
        if (customData is Map) {
          for (final entry in customData.entries) {
            _branchParams[entry.key.toString()] = entry.value.toString();
          }
          print('Extracted custom Branch params: $_branchParams');
        } else if (customData is String &&
            customData.startsWith('{') &&
            customData.endsWith('}')) {
          print('Custom data might be a JSON string: $customData');
        }
      }
    } catch (e) {
      print('Error extracting custom Branch data: $e');
    }
  }

  void _navigateBasedOnPath(String path) {
    try {
      print('Navigating based on path: $path, Params: $_branchParams');
      switch (path.toLowerCase()) {
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
          print('Unhandled path in _navigateBasedOnPath: $path');
          goRouter.go('/');
          break;
      }
    } catch (e) {
      print('Error in _navigateBasedOnPath for path $path: $e');
      goRouter.go('/');
    }
  }

  Future<void> handleDeepLink(String url) async {
    try {
      if (_isProcessingDeepLink) {
        print('Deep link received while another is processing. Ignoring: $url');
        return;
      }

      _isProcessingDeepLink = true;
      print('Handling external deep link: $url');

      final uri = Uri.parse(url);
      _processIncomingLink(uri);

      FlutterBranchSdk.handleDeepLink(url);
    } catch (e) {
      print('Error parsing or handling external deep link $url: $e');
    } finally {
      _isProcessingDeepLink = false;
    }
  }

  void _navigateToStats(String path, Map<String, String> params) {
    try {
      print('Navigating to Stats - Path: $path, Params: $params');
      DateTime? minDate, maxDate;
      try {
        minDate = params['minDate'] != null
            ? DateTime.parse(params['minDate']!)
            : null;
      } catch (_) {}
      try {
        maxDate = params['maxDate'] != null
            ? DateTime.parse(params['maxDate']!)
            : null;
      } catch (_) {}

      final filters = TransactionFilters(
        minDate: minDate,
        maxDate: maxDate,
        categories: params['categories']?.split(','),
        accountsIDs: params['accounts']?.split(','),
        tagsIDs: params['tags']?.split(','),
        searchValue: params['search'],
      );

      switch (path.toLowerCase()) {
        case 'category':
          goRouter.go(AppRoutes.statsCategory(params['category'] ?? '',
              filters: filters));
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
        case '':
          goRouter.go('/stats', extra: filters);
          break;
        default:
          print('Unhandled stats path: $path');
          goRouter.go('/stats');
          break;
      }
    } catch (e) {
      print('Error navigating to stats: $e');
      goRouter.go('/stats');
    }
  }

  Future<void> dispose() async {
    await _branchSubscription?.cancel();
    _branchSubscription = null;
    _branchParams.clear();
    print('LinkHandlerService disposed.');
  }
}
