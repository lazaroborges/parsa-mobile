import 'package:flutter/material.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/routes/go_router_config.dart';
import 'package:parsa/main.dart'; // Import to access navigatorKey

/// A delegate that handles navigation requests from services
/// and provides context-aware navigation when possible
class NavigationDelegate {
  static final NavigationDelegate _instance = NavigationDelegate._();
  static NavigationDelegate get instance => _instance;

  NavigationDelegate._();

  /// Navigate to a route using the global navigator key
  void navigateTo(String route, {Object? extra}) {
    print('DEBUG: NavigationDelegate: Navigating to $route');
    try {
      // Use the global navigatorKey instead of goRouter
      if (navigatorKey.currentState != null) {
        // Special case for home route
        if (route == '/' || route.isEmpty) {
          print('DEBUG: NavigationDelegate: Navigating to home page');
          // Pop to root for home navigation
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        } else {
          print(
              'DEBUG: NavigationDelegate: Using navigatorKey.currentState.pushNamed for $route');
          navigatorKey.currentState!.pushNamed(route, arguments: extra);
        }
      } else {
        print('ERROR: NavigationDelegate: Navigator is not available');
      }
    } catch (e) {
      print('ERROR: NavigationDelegate: Failed to navigate to $route: $e');
      // Fallback to home route on error
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      }
    }
  }

  /// Navigate to an account after fetching the account data
  Future<void> navigateToAccount(String accountId) async {
    print('DEBUG: NavigationDelegate: Navigating to account $accountId');
    try {
      // First fetch the account to use as extra data
      final account =
          await AccountService.instance.getAccountById(accountId).first;

      if (account != null) {
        print(
            'DEBUG: NavigationDelegate: Account found, navigating to details');
        navigateTo('/accounts/$accountId', extra: account);
      } else {
        print(
            'DEBUG: NavigationDelegate: Account not found, navigating to list');
        navigateTo('/accounts');
      }
    } catch (e) {
      print(
          'ERROR: NavigationDelegate: Failed to fetch account $accountId: $e');
      navigateTo('/accounts');
    }
  }

  /// Navigate to a budget after fetching the budget data
  Future<void> navigateToBudget(String budgetId) async {
    print('DEBUG: NavigationDelegate: Navigating to budget $budgetId');
    try {
      final budget = await BudgetServive.instance.getBudgetById(budgetId).first;

      if (budget != null) {
        print('DEBUG: NavigationDelegate: Budget found, navigating to details');
        navigateTo('/budgets/$budgetId', extra: budget);
      } else {
        print(
            'DEBUG: NavigationDelegate: Budget not found, navigating to list');
        navigateTo('/budgets');
      }
    } catch (e) {
      print('ERROR: NavigationDelegate: Failed to fetch budget $budgetId: $e');
      navigateTo('/budgets');
    }
  }

  /// Navigate to a transaction after fetching the transaction data
  Future<void> navigateToTransaction(String transactionId) async {
    print(
        'DEBUG: NavigationDelegate: Navigating to transaction $transactionId');
    try {
      final transaction = await TransactionService.instance
          .getTransactionById(transactionId)
          .first;

      if (transaction != null) {
        print(
            'DEBUG: NavigationDelegate: Transaction found, navigating to details');
        navigateTo('/transactions/$transactionId', extra: transaction);
      } else {
        print(
            'DEBUG: NavigationDelegate: Transaction not found, navigating to list');
        navigateTo('/transactions');
      }
    } catch (e) {
      print(
          'ERROR: NavigationDelegate: Failed to fetch transaction $transactionId: $e');
      navigateTo('/transactions');
    }
  }

  /// Navigate to stats with filters
  void navigateToStats(String path, Map<String, String> params) {
    print(
        'DEBUG: NavigationDelegate: Navigating to stats with path: $path, params: $params');
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

        // Create URI with query parameters
        if (queryParams.isNotEmpty) {
          final uri = Uri(path: route, queryParameters: queryParams);
          route = uri.toString();
        }
      }

      navigateTo(route);
    } catch (e) {
      print('ERROR: NavigationDelegate: Failed to navigate to stats: $e');
      navigateTo('/stats');
    }
  }
}
