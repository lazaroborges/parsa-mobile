import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/routes/go_router_config.dart';

class LinkHandlerService {
  static final LinkHandlerService instance = LinkHandlerService._();
  LinkHandlerService._();

  StreamSubscription<Map>? _branchSubscription;
  final Map<String, String> _branchParams = {};

  Future<void> initialize() async {
    try {
      // Set up session listener for Branch deep links
      _branchSubscription = FlutterBranchSdk.listSession().listen(
        (data) => _handleDeepLinkData(data),
        onError: (error) => debugPrint('Branch session listener error: $error'),
      );

      // Check initial referring data
      await _checkInitialReferringData();
    } catch (e) {
      debugPrint('Error initializing link handler: $e');
    }
  }

  Future<void> _checkInitialReferringData() async {
    try {
      final initialParams = await FlutterBranchSdk.getFirstReferringParams();
      if (initialParams.isNotEmpty) {
        _handleDeepLinkData(initialParams);
      }

      final latestParams = await FlutterBranchSdk.getLatestReferringParams();
      if (latestParams.isNotEmpty) {
        debugPrint('Latest referring data: $latestParams');
      }
    } catch (e) {
      debugPrint('Error checking initial referring data: $e');
    }
  }

  void _handleDeepLinkData(Map<dynamic, dynamic> data) {
    debugPrint('Deep link data received: $data');

    try {
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        final String? linkPath = data['+deeplink_path'] as String?;
        final bool isFirstSession = data['+is_first_session'] ?? false;

        debugPrint('Is first session: $isFirstSession');
        debugPrint('Deep link path: $linkPath');

        _extractAndSaveCustomData(data);

        if (linkPath != null) {
          _navigateBasedOnPath(linkPath);
        }
      } else {
        // Handle direct URL scheme links like myapp://budgets/id=28312832h38
        final String? url = data['~referring_link'] as String?;
        if (url != null) {
          final Uri uri = Uri.parse(url);
          _handleDeepLink(uri);
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link data: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    // Extract the path without the scheme
    final path =
        uri.path.isNotEmpty ? uri.path : uri.toString().split('://').last;

    debugPrint('Handling deep link with path: $path');

    // Handle different path patterns

    // Budget deep links
    if (path.startsWith('budgets/id=')) {
      final budgetId = path.substring('budgets/id='.length);
      _navigateToBudget(budgetId);
    } else if (path.startsWith('budgets') &&
        uri.queryParameters.containsKey('id')) {
      final budgetId = uri.queryParameters['id']!;
      _navigateToBudget(budgetId);
    }

    // Transaction deep links
    else if (path.startsWith('transactions/id=')) {
      final transactionId = path.substring('transactions/id='.length);
      _navigateToTransaction(transactionId);
    } else if (path.startsWith('transactions') &&
        uri.queryParameters.containsKey('id')) {
      final transactionId = uri.queryParameters['id']!;
      _navigateToTransaction(transactionId);
    }

    // Account deep links
    else if (path.startsWith('accounts/id=')) {
      final accountId = path.substring('accounts/id='.length);
      _navigateToAccount(accountId);
    } else if (path.startsWith('accounts') &&
        uri.queryParameters.containsKey('id')) {
      final accountId = uri.queryParameters['id']!;
      _navigateToAccount(accountId);
    }

    // Stats deep links
    else if (path.startsWith('stats/')) {
      final statsPath = path.substring('stats/'.length);
      _navigateToStats(statsPath, uri.queryParameters);
    } else if (path == 'stats') {
      _navigateToStats('', uri.queryParameters);
    }

    // Default fallback
    else {
      // Default fallback navigation
      _navigateBasedOnPath(path.split('/').first);
    }
  }

  void _navigateToBudget(String budgetId) {
    debugPrint('Navigating to budget with ID: $budgetId');

    // Fetch the budget data first
    BudgetServive.instance.getBudgetById(budgetId).first.then((budget) {
      if (budget != null) {
        // Navigate with the fetched budget data
        goRouter.go(AppRoutes.budget(budgetId, budget: budget));
        debugPrint('Navigated to budget with ID: $budgetId');
      } else {
        // Budget not found, navigate to budgets list
        debugPrint('Budget with ID $budgetId not found, going to budgets list');
        goRouter.go(AppRoutes.budgets());
      }
    }).catchError((error) {
      debugPrint('Error fetching budget data: $error');
      goRouter.go(AppRoutes.budgets());
    });
  }

  void _navigateToTransaction(String transactionId) {
    debugPrint('Navigating to transaction with ID: $transactionId');

    // Fetch the transaction data first
    TransactionService.instance
        .getTransactionById(transactionId)
        .first
        .then((transaction) {
      if (transaction != null) {
        // For single transaction view, we don't need filters
        goRouter
            .go(AppRoutes.transaction(transactionId, transaction: transaction));
        debugPrint('Navigated to transaction with ID: $transactionId');
      } else {
        // Transaction not found, navigate to transactions list
        debugPrint(
            'Transaction with ID $transactionId not found, going to transactions list');
        goRouter.go(AppRoutes.transactions());
      }
    }).catchError((error) {
      debugPrint('Error fetching transaction data: $error');
      goRouter.go(AppRoutes.transactions());
    });
  }

  void _navigateToAccount(String accountId) {
    debugPrint('Navigating to account with ID: $accountId');

    // Fetch the account data first
    AccountService.instance.getAccountById(accountId).first.then((account) {
      if (account != null) {
        // Navigate with the fetched account data
        goRouter.go(AppRoutes.account(accountId, account: account));
        debugPrint('Navigated to account with ID: $accountId');
      } else {
        // Account not found, navigate to accounts list
        debugPrint(
            'Account with ID $accountId not found, going to accounts list');
        goRouter.go(AppRoutes.accounts());
      }
    }).catchError((error) {
      debugPrint('Error fetching account data: $error');
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
      debugPrint('Error extracting custom data: $e');
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
      debugPrint('Error navigating to path: $e');
      goRouter.go('/');
    }
  }

  Future<void> handleDeepLink(String url) async {
    try {
      // Parse URL and handle it
      final uri = Uri.parse(url);
      _handleDeepLink(uri);

      // Additionally, let Branch SDK handle it for analytics
      FlutterBranchSdk.handleDeepLink(url);
      debugPrint('Handled deep link: $url');
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  Future<bool> listOnSearch(BranchUniversalObject buo) async {
    try {
      return await FlutterBranchSdk.listOnSearch(buo: buo);
    } catch (e) {
      debugPrint('Error listing on search: $e');
      return false;
    }
  }

  Future<bool> removeFromSearch(BranchUniversalObject buo) async {
    try {
      return await FlutterBranchSdk.removeFromSearch(buo: buo);
    } catch (e) {
      debugPrint('Error removing from search: $e');
      return false;
    }
  }

  void registerView(BranchUniversalObject buo) {
    try {
      FlutterBranchSdk.registerView(buo: buo);
    } catch (e) {
      debugPrint('Error registering view: $e');
    }
  }

  void trackContent({
    required List<BranchUniversalObject> buo,
    required BranchEvent branchEvent,
  }) {
    try {
      FlutterBranchSdk.trackContent(buo: buo, branchEvent: branchEvent);
    } catch (e) {
      debugPrint('Error tracking content: $e');
    }
  }

  void trackContentWithoutBuo(BranchEvent branchEvent) {
    try {
      FlutterBranchSdk.trackContentWithoutBuo(branchEvent: branchEvent);
    } catch (e) {
      debugPrint('Error tracking content without BUO: $e');
    }
  }

  void _navigateToStats(String path, Map<String, String> params) {
    debugPrint('Navigating to stats with path: $path');

    try {
      // Parse filters from params
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

      // Determine which stats page to show based on path
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
      debugPrint('Error navigating to stats: $e');
      goRouter.go('/stats');
    }
  }

  Future<void> dispose() async {
    await _branchSubscription?.cancel();
    _branchSubscription = null;
    _branchParams.clear();
  }
}
