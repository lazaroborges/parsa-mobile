import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/main.dart';

class NavigationDelegate {
  static final NavigationDelegate _instance = NavigationDelegate._();
  static NavigationDelegate get instance => _instance;

  NavigationDelegate._();

  Future<void> navigateToAppRoute(String route, {String? id}) async {
    try {
      switch (route) {
        case 'dashboard':
          tabsPageKey.currentState?.navigateToTab(0);
          break;
        case 'transactions':
          tabsPageKey.currentState?.navigateToTab(1);
          break;
        case 'stats':
          tabsPageKey.currentState?.navigateToStatsTabWithIndex(0);
          break;
        case 'stats/category':
          tabsPageKey.currentState?.navigateToStatsTabWithIndex(1);
          break;
        case 'stats/subcategory':
          tabsPageKey.currentState?.navigateToStatsTabWithIndex(2);
          break;
        case 'stats/cash-flow':
          tabsPageKey.currentState?.navigateToStatsTabWithIndex(3);
          break;
        case 'stats/financial-health':
          tabsPageKey.currentState?.navigateToStatsTabWithIndex(4);
          break;
        case 'stats/balance-evolution':
          tabsPageKey.currentState?.navigateToStatsTabWithIndex(5);
          break;
        case 'settings':
          tabsPageKey.currentState?.navigateToTab(3);
          break;
        case 'accounts':
          navigatorKey.currentState?.pushNamed('/accounts');
          break;
        case 'accounts/id':
          if (id != null) {
            final account =
                await AccountService.instance.getAccountById(id).first;
            if (account != null) {
              navigatorKey.currentState?.pushNamed('/accounts/$id');
            } else {
              navigatorKey.currentState?.pushNamed('/accounts');
            }
          }
          break;
        case 'budgets':
          navigatorKey.currentState?.pushNamed('/budgets');
          break;
        case 'budgets/id':
          if (id != null) {
            final budget = await BudgetService.instance.getBudgetById(id).first;
            if (budget != null) {
              navigatorKey.currentState?.pushNamed('/budgets/$id');
            } else {
              navigatorKey.currentState?.pushNamed('/budgets');
            }
          }
          break;
        case 'tags':
          navigatorKey.currentState?.pushNamed('/tags');
          break;
        case 'tags/id':
          if (id != null) {
            navigatorKey.currentState?.pushNamed('/tags/$id');
          }
          break;
        case 'transactions/id':
          if (id != null) {
            final transaction =
                await TransactionService.instance.getTransactionById(id).first;
            if (transaction != null) {
              navigatorKey.currentState?.pushNamed('/transactions/$id');
            } else {
              tabsPageKey.currentState?.navigateToTab(1);
            }
          }
          break;
        case 'subscription':
          navigatorKey.currentState?.pushNamed('/subscription');
          break;
        default:
          tabsPageKey.currentState?.navigateToTab(0);
      }
    } catch (e) {
      print('Error: Failed to navigate to $route: $e');
      tabsPageKey.currentState?.navigateToTab(0);
    }
  }
}
