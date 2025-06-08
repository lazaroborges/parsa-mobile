import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/main.dart';
import 'package:flutter/widgets.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';

class NavigationDelegate {
  static final NavigationDelegate _instance = NavigationDelegate._();
  static NavigationDelegate get instance => _instance;

  NavigationDelegate._();

  void _deferTabNavigation(VoidCallback nav) {
    if (tabsPageKey.currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => nav());
    } else {
      nav();
    }
  }

  Future<Map<String, String>> _convertCategoryNamesToIds(
      Map<String, String> queryParams) async {
    if (queryParams.containsKey('categories')) {
      final names = queryParams['categories']!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      List<String> ids = [];
      for (final name in names) {
        final cat =
            await CategoryService.instance.getCategoryByName(name).first;
        if (cat != null) ids.add(cat.id);
      }
      if (ids.isNotEmpty) {
        final qp = Map<String, String>.from(queryParams);
        qp['categories'] = ids.join(',');
        return qp;
      }
    }
    return queryParams;
  }

  Future<void> navigateToAppRoute(String route,
      {String? id, dynamic data, Map<String, String>? queryParams}) async {
    try {
      switch (route) {
        case 'dashboard':
          _deferTabNavigation(() => tabsPageKey.currentState?.navigateToTab(0));
          break;
        case 'transactions':
          if (queryParams != null && queryParams.isNotEmpty) {
            final qp = await _convertCategoryNamesToIds(queryParams);
            _deferTabNavigation(() => tabsPageKey.currentState
                ?.navigateToTransactionsTab(TransactionFilters.fromMap(qp)));
          } else {
            _deferTabNavigation(
                () => tabsPageKey.currentState?.navigateToTab(1));
          }
          break;
        case 'stats':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTab(0));
          break;
        case 'stats/category':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTab(0));
          break;
        case 'stats/subcategory':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTab(1));
          break;
        case 'stats/cash-flow':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTab(2));
          break;
        case 'stats/financial-health':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTab(3));
          break;
        case 'stats/balance-evolution':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTab(4));
          break;
        case 'settings':
          _deferTabNavigation(() => tabsPageKey.currentState?.navigateToTab(3));
          break;
        case 'accounts':
          navigatorKey.currentState?.pushNamed('/accounts');
          break;
        case 'accounts/id':
          if (id != null) {
            final account =
                data ?? await AccountService.instance.getAccountById(id).first;
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
            final budget =
                data ?? await BudgetService.instance.getBudgetById(id).first;
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
            final tag = data;
            if (tag != null) {
              navigatorKey.currentState?.pushNamed('/tags/$id');
            } else {
              navigatorKey.currentState?.pushNamed('/tags');
            }
          }
          break;
        case 'transactions/id':
          if (id != null) {
            final transaction = data ??
                await TransactionService.instance.getTransactionById(id).first;
            if (transaction != null) {
              navigatorKey.currentState
                  ?.pushReplacementNamed('/transactions/$id');
            } else {
              tabsPageKey.currentState?.navigateToTab(1);
            }
          }
          break;
        case 'subscription':
          navigatorKey.currentState?.pushReplacementNamed('/subscription');
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
