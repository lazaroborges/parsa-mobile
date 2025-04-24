import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/main.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/app/layout/tabs.dart';

/// A delegate that handles navigation requests from services
/// and provides context-aware navigation when possible
class NavigationDelegate {
  static final NavigationDelegate _instance = NavigationDelegate._();
  static NavigationDelegate get instance => _instance;

  NavigationDelegate._();

  /// Navigate to a route using the global navigator key
  void navigateTo(String route, {Object? queryParams}) {
    try {
      // Make sure the route starts with a forward slash
      final normalizedRoute = route.startsWith('/') ? route : '/$route';

      if (kDebugMode) {
        print(
            'Navigating to route: $normalizedRoute with params: $queryParams');
      }

      // Use the global navigatorKey instead of goRouter
      if (navigatorKey.currentState != null) {
        // Special case for home route
        if (normalizedRoute == '/' || normalizedRoute.isEmpty) {
          // Pop to root for home navigation
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
          // Ensure the dashboard tab is selected
          if (tabsPageKey.currentState != null) {
            tabsPageKey.currentState!.navigateToTab(0);
          }
        } else {
          // Check if we are already in TabsPage context
          bool isInTabsPage = false;
          navigatorKey.currentContext?.visitAncestorElements((element) {
            if (element.widget is TabsPage) {
              isInTabsPage = true;
              return false;
            }
            return true;
          });

          if (isInTabsPage && tabsPageKey.currentState != null) {
            // Map routes to tab indices
            int tabIndex = 0;
            if (normalizedRoute.startsWith('/stats')) {
              tabIndex = 3; // Assuming stats is the 4th tab (index 3)
            } else if (normalizedRoute.startsWith('/transactions')) {
              tabIndex = 2; // Assuming transactions is the 3rd tab (index 2)
            } else if (normalizedRoute.startsWith('/budgets')) {
              tabIndex = 1; // Assuming budgets is the 2nd tab (index 1)
            } else if (normalizedRoute.startsWith('/accounts')) {
              tabIndex = 4; // Assuming accounts is the 5th tab (index 4)
            }
            // Navigate to the correct tab
            tabsPageKey.currentState!.navigateToTab(tabIndex);
            // If there are query parameters or specific sub-routes, handle them within the tab
            if (queryParams != null || normalizedRoute.contains('/')) {
              navigatorKey.currentState!
                  .pushNamed(normalizedRoute, arguments: queryParams);
            }
          } else {
            // If not in TabsPage, pop to root and then navigate
            navigatorKey.currentState!.popUntil((route) => route.isFirst);
            // Now push the TabsPage if needed, or ensure the correct tab is selected
            if (tabsPageKey.currentState != null) {
              int tabIndex = 0;
              if (normalizedRoute.startsWith('/stats')) {
                tabIndex = 3;
              } else if (normalizedRoute.startsWith('/transactions')) {
                tabIndex = 2;
              } else if (normalizedRoute.startsWith('/budgets')) {
                tabIndex = 1;
              } else if (normalizedRoute.startsWith('/accounts')) {
                tabIndex = 4;
              }
              tabsPageKey.currentState!.navigateToTab(tabIndex);
              if (queryParams != null || normalizedRoute.contains('/')) {
                navigatorKey.currentState!
                    .pushNamed(normalizedRoute, arguments: queryParams);
              }
            } else {
              // Fallback to pushing the route directly if TabsPage state is not available
              navigatorKey.currentState!
                  .pushNamed(normalizedRoute, arguments: queryParams);
            }
          }
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
      if (kDebugMode) {
        print('Attempting to fetch budget with ID: $budgetId');
      }
      final budget = await BudgetServive.instance.getBudgetById(budgetId).first;

      if (budget != null) {
        navigateTo('/budgets/$budgetId');
      } else {
        navigateTo('/budgets');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: Failed to fetch budget $budgetId: $e');
      }
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
    if (kDebugMode) {
      print('NavigationDelegate: Processing notification route: $route');
      print('NavigationDelegate: Query parameters: $queryParams');
    }

    final segments = route.split('/');
    if (segments.isEmpty) return;

    final section = segments[0].toLowerCase();
    final id = segments.length > 1 ? segments[1] : null;

    if (kDebugMode) {
      print('Navigating to $route with queryParams: $queryParams');
      print('Section: $section');
      print('Id: $id');
    }

    switch (section) {
      case '':
        navigateTo('/');
        break;
      case 'dashboard':
        // Navigate to home/dashboard
        navigateTo('/');
        break;
      case 'budgets':
        if (id != null) {
          // Use direct route path with ID for budgets
          navigateTo('/budgets/$id');
        } else {
          navigateTo('/budgets');
        }
        break;
      case 'transactions':
        if (id != null) {
          // Use direct route path with ID for transactions
          navigateTo('/transactions/$id');
        } else if (queryParams != null) {
          navigateToTransaction(params: queryParams);
        } else {
          navigateTo('/transactions');
        }
        break;
      case 'accounts':
        if (id != null) {
          // Use direct route path with ID for accounts
          navigateTo('/accounts/$id');
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
