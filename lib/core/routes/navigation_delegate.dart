import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/main.dart';
import 'package:flutter/widgets.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/database/services/category/category_service.dart';

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
      // If queryParams are present and this is a tab route, use tab navigation
      if (queryParams != null && queryParams.isNotEmpty && id == null) {
        Map<String, String> qp = queryParams;
        if (route.startsWith('stats') || route == 'transactions') {
          qp = await _convertCategoryNamesToIds(queryParams);
        }
        if (route.startsWith('stats')) {
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: _statsTabIndexFromRoute(route),
                    filters: TransactionFilters.fromMap(qp),
                  ));
          return;
        } else if (route == 'transactions') {
          _deferTabNavigation(() =>
              tabsPageKey.currentState?.navigateToTransactionsTabWithFilters(
                filters: TransactionFilters.fromMap(qp),
              ));
          return;
        }
        // For non-tab routes, fallback to pushNamed
        navigatorKey.currentState
            ?.pushNamed('/$route', arguments: {'queryParams': qp});
        return;
      }
      switch (route) {
        case 'dashboard':
          _deferTabNavigation(() => tabsPageKey.currentState?.navigateToTab(0));
          break;
        case 'transactions':
          _deferTabNavigation(() =>
              tabsPageKey.currentState?.navigateToTransactionsTabWithFilters(
                filters: queryParams != null && queryParams.isNotEmpty
                    ? TransactionFilters.fromMap(queryParams)
                    : null,
              ));
          break;
        case 'stats':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: 0,
                    filters: queryParams != null && queryParams.isNotEmpty
                        ? TransactionFilters.fromMap(queryParams)
                        : null,
                  ));
          break;
        case 'stats/category':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: 0,
                    filters: queryParams != null && queryParams.isNotEmpty
                        ? TransactionFilters.fromMap(queryParams)
                        : null,
                  ));
          break;
        case 'stats/subcategory':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: 1,
                    filters: queryParams != null && queryParams.isNotEmpty
                        ? TransactionFilters.fromMap(queryParams)
                        : null,
                  ));
          break;
        case 'stats/cash-flow':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: 2,
                    filters: queryParams != null && queryParams.isNotEmpty
                        ? TransactionFilters.fromMap(queryParams)
                        : null,
                  ));
          break;
        case 'stats/financial-health':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: 3,
                    filters: queryParams != null && queryParams.isNotEmpty
                        ? TransactionFilters.fromMap(queryParams)
                        : null,
                  ));
          break;
        case 'stats/balance-evolution':
          _deferTabNavigation(
              () => tabsPageKey.currentState?.navigateToStatsTabWithFilters(
                    index: 4,
                    filters: queryParams != null && queryParams.isNotEmpty
                        ? TransactionFilters.fromMap(queryParams)
                        : null,
                  ));
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
              navigatorKey.currentState?.pushNamed('/transactions/$id');
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

  int _statsTabIndexFromRoute(String route) {
    switch (route) {
      case 'stats':
      case 'stats/category':
        return 0;
      case 'stats/subcategory':
        return 1;
      case 'stats/cash-flow':
        return 2;
      case 'stats/financial-health':
        return 3;
      case 'stats/balance-evolution':
        return 4;
      default:
        return 0;
    }
  }
}
