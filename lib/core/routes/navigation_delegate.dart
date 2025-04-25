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
      // Only allow pushing detail pages (with an id) as subroutes
      final normalizedRoute = route.startsWith('/') ? route : '/$route';
      final parts = normalizedRoute.split('/');
      final section = parts.length > 1 ? parts[1] : '';
      final id = parts.length > 2 ? parts[2] : null;

      // Map section to tab index
      final tabIndex = {
            'stats': 3,
            'transactions': 2,
            'accounts': 4,
            'budgets': 1,
          }[section] ??
          0;

      // Always select the correct tab for list pages
      if (tabsPageKey.currentState != null) {
        tabsPageKey.currentState!.navigateToTab(tabIndex);
      }

      // Only push detail pages (with id)
      if (id != null && navigatorKey.currentState != null) {
        final subRoute = '/$section/$id';
        navigatorKey.currentState!.pushNamed(subRoute);
      }
    } catch (e) {
      print('Error: Failed to navigate to $route: $e');
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

  /// Navigate to a transaction detail page or select the tab for the list
  Future<void> navigateToTransaction(
      {String? transactionId, Map<String, String>? params}) async {
    try {
      if (transactionId != null) {
        // Only push detail page
        navigateTo('/transactions/$transactionId');
      } else {
        // Just select the tab for the list
        if (tabsPageKey.currentState != null) {
          tabsPageKey.currentState!.navigateToTab(2);
        }
      }
    } catch (e) {
      print('Error: Failed to fetch transaction $transactionId: $e');
      if (tabsPageKey.currentState != null) {
        tabsPageKey.currentState!.navigateToTab(2);
      }
    }
  }

  /// Navigate to stats tab only (no full-screen push)
  void navigateToStats() {
    if (tabsPageKey.currentState != null) {
      tabsPageKey.currentState!.navigateToTab(3);
    }
  }

  /// Handles notification and deeplink navigation in a minimal, tab-first way
  void navigateBasedOnNotificationRoute(String route) {
    // 1. Parse "section/id"
    final parts = route.split('/');
    final section = parts[0].toLowerCase();
    final id = parts.length > 1 ? parts[1] : null;

    // 2. Map section → tab index
    final tabIndex = {
          'transactions': 2,
          'accounts': 4, // Settings remains 4 on phones, accounts on tablets
          'stats': 3,
        }[section] ??
        0; // default → Dashboard

    // 3. Bring the right tab to the front
    if (tabsPageKey.currentState != null) {
      tabsPageKey.currentState!.navigateToTab(tabIndex);
    }

    // 4. If we have an entity ID, push it inside *that tab's* Navigator
    if (id != null && navigatorKey.currentState != null) {
      final subRoute = '/$section/$id';
      navigatorKey.currentState!.pushNamed(subRoute);
    }
  }
}
