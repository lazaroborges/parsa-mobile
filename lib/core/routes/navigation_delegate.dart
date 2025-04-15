import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/main.dart';

/// A delegate that handles navigation requests from services
/// and provides context-aware navigation when possible
class NavigationDelegate {
  static final NavigationDelegate _instance = NavigationDelegate._();
  static NavigationDelegate get instance => _instance;

  NavigationDelegate._();

  /// Navigate to a route using the global navigator key
  void navigateTo(String route, {Object? queryParams}) {
    try {
      // Use the global navigatorKey instead of goRouter
      if (navigatorKey.currentState != null) {
        // Special case for home route
        if (route == '/' || route.isEmpty) {
          // Pop to root for home navigation
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        } else {
          navigatorKey.currentState!.pushNamed(route, arguments: queryParams);
        }
      } else {
        print('Error: Navigator is not available');
      }
    } catch (e) {
      print('Error: Failed to navigate to $route: $e');
      // Fallback to home route on error
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
    }
  }

  /// Navigate to an account after fetching the account data
  Future<void> navigateToAccount(String accountId) async {
    try {
      // First check if account exists
      final account =
          await AccountService.instance.getAccountById(accountId).first;

      if (account != null) {
        navigateTo('/accounts/$accountId');
      } else {
        navigateTo('/accounts');
      }
    } catch (e) {
      print('Error: Failed to fetch account $accountId: $e');
      navigateTo('/accounts');
    }
  }

  /// Navigate to a budget after fetching the budget data
  Future<void> navigateToBudget(String budgetId) async {
    try {
      final budget = await BudgetServive.instance.getBudgetById(budgetId).first;

      if (budget != null) {
        navigateTo('/budgets/$budgetId');
      } else {
        navigateTo('/budgets');
      }
    } catch (e) {
      print('Error: Failed to fetch budget $budgetId: $e');
      navigateTo('/budgets');
    }
  }

  /// Navigate to a specific transaction by ID or to transactions with filters
  /// Either transactionId or params should be provided, not both
  Future<void> navigateToTransaction(
      {String? transactionId, Map<String, String>? params}) async {
    try {
      // Case 1: Navigate to a specific transaction by ID
      if (transactionId != null && (params == null || params.isEmpty)) {
        final transaction = await TransactionService.instance
            .getTransactionById(transactionId)
            .first;

        if (transaction != null) {
          navigateTo('/transactions/$transactionId');
        } else {
          navigateTo('/transactions');
        }
        return;
      }

      // Case 2: Navigate to transactions with query parameters
      if (params != null && params.isNotEmpty && transactionId == null) {
        final queryParams = <String, String>{};

        // Add only the params we support in filters
        if (params.containsKey('minDate'))
          queryParams['minDate'] = params['minDate']!;
        if (params.containsKey('maxDate'))
          queryParams['maxDate'] = params['maxDate']!;
        if (params.containsKey('categories'))
          queryParams['categories'] = params['categories']!;
        if (params.containsKey('accounts'))
          queryParams['accounts'] = params['accounts']!;
        if (params.containsKey('tags')) queryParams['tags'] = params['tags']!;
        if (params.containsKey('search'))
          queryParams['search'] = params['search']!;

        // Pass the query parameters directly
        navigateTo('/transactions', queryParams: queryParams);
        return;
      }

      // Default: Navigate to transactions list
      navigateTo('/transactions');
    } catch (e) {
      print('Error: Failed to fetch transaction $transactionId: $e');
      navigateTo('/transactions');
    }
  }

  /// Navigate to stats with filters
  void navigateToStats(String path, Map<String, String> params) {
    try {
      String route = '/stats';

      if (path.isNotEmpty) {
        route = '$route/$path';
      }

      // If we have filter params, build a query string
      if (params.isNotEmpty) {
        final queryParams = <String, String>{};

        // Add only the params we support in filters
        if (params.containsKey('minDate'))
          queryParams['minDate'] = params['minDate']!;
        if (params.containsKey('maxDate'))
          queryParams['maxDate'] = params['maxDate']!;
        if (params.containsKey('categories'))
          queryParams['categories'] = params['categories']!;
        if (params.containsKey('accounts'))
          queryParams['accounts'] = params['accounts']!;
        if (params.containsKey('tags')) queryParams['tags'] = params['tags']!;
        if (params.containsKey('search'))
          queryParams['search'] = params['search']!;

        // Pass the query parameters directly
        navigateTo(route, queryParams: queryParams);
      } else {
        navigateTo(route);
      }
    } catch (e) {
      print('Error: Failed to navigate to stats: $e');
      navigateTo('/stats');
    }
  }

  // Add a new method to handle notification routes
  void navigateBasedOnNotificationRoute(String route,
      {Map<String, String>? queryParams}) {
    final segments = route.split('/');
    if (segments.isEmpty) return;

    final section = segments[0].toLowerCase();
    final id = segments.length > 1 ? segments[1] : null;

    switch (section) {
      case 'budgets':
        if (id != null) {
          navigateToBudget(id);
        } else {
          navigateTo('/budgets');
        }
        break;
      case 'transactions':
        if (id != null) {
          navigateToTransaction(transactionId: id);
        } else if (queryParams != null) {
          navigateToTransaction(params: queryParams);
        } else {
          navigateTo('/transactions');
        }
        break;
      case 'accounts':
        if (id != null) {
          navigateToAccount(id);
        } else {
          navigateTo('/accounts');
        }
        break;
      case 'stats':
        if (queryParams != null) {
          navigateToStats('', queryParams);
        } else {
          navigateTo('/stats');
        }
        break;
      default:
        navigateTo('/');
        break;
    }
  }
}
