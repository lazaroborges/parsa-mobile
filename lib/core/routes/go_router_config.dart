import 'package:go_router/go_router.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/app/home/dashboard.page.dart';
import 'package:parsa/app/budgets/budgets.page.dart';
import 'package:parsa/app/budgets/budget_details.page.dart';
import 'package:parsa/app/settings/subscriptions/subscription_page.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/app/transactions/transaction_details.page.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/app/settings/settings.page.dart';
import 'package:parsa/app/settings/preferences_settings.page.dart';
import 'package:parsa/app/settings/about.page.dart';
import 'package:parsa/app/settings/export.page.dart';
import 'package:parsa/app/accounts/all_accounts.page.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/transaction/transaction.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => const TabsPage(),
      routes: [
        // Dashboard Route
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardPage(),
        ),

        // Accounts Section
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AllAccountsPage(),
          routes: [
            GoRoute(
              path: ':accountId',
              builder: (context, state) {
                final accountId = state.pathParameters['accountId']!;
                final account = state.extra as Account;

                return AccountDetailsPage(
                    account: account, accountIconHeroTag: 'account-$accountId');
              },
              routes: [
                GoRoute(
                  path: 'transactions',
                  builder: (context, state) {
                    final accountId = state.pathParameters['accountId']!;
                    final filters = _parseFilters(state.uri.queryParameters);

                    return TransactionsPage(
                      filters: filters.copyWith(
                        accountsIDs: [accountId],
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'stats',
                  builder: (context, state) {
                    final accountId = state.pathParameters['accountId']!;
                    final filters = _parseFilters(state.uri.queryParameters);

                    return StatsPage(
                      filters: filters.copyWith(
                        accountsIDs: [accountId],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Stats Routes
        GoRoute(
          path: '/stats',
          builder: (context, state) {
            final filters = _parseFilters(state.uri.queryParameters);
            return StatsPage(filters: filters);
          },
          routes: [
            GoRoute(
              path: 'category',
              builder: (context, state) {
                final filters = _parseFilters(state.uri.queryParameters);

                return StatsPage(initialIndex: 0, filters: filters);
              },
            ),
            GoRoute(
              path: 'subcategory',
              builder: (context, state) {
                final filters = _parseFilters(state.uri.queryParameters);
                return StatsPage(initialIndex: 1, filters: filters);
              },
            ),
            GoRoute(
              path: 'cash-flow',
              builder: (context, state) {
                final filters = _parseFilters(state.uri.queryParameters);
                return StatsPage(initialIndex: 2, filters: filters);
              },
            ),
            GoRoute(
              path: 'financial-health',
              builder: (context, state) {
                final filters = _parseFilters(state.uri.queryParameters);
                return StatsPage(initialIndex: 3, filters: filters);
              },
            ),
            GoRoute(
              path: 'balance-evolution',
              builder: (context, state) {
                final filters = _parseFilters(state.uri.queryParameters);
                return StatsPage(initialIndex: 4, filters: filters);
              },
            ),
          ],
        ),

        // Transactions Routes
        GoRoute(
          path: '/transactions',
          builder: (context, state) {
            final filters = _parseFilters(state.uri.queryParameters);
            return TransactionsPage(filters: filters);
          },
          // routes: [
          //   GoRoute(
          //     path: ':transactionId',
          //     builder: (context, state) {
          //       final transactionId = state.pathParameters['transactionId']!;
          //       final transaction = state.extra as MoneyTransaction?;

          //       return TransactionDetailsPage(
          //         prevPage: const TabsPage(),
          //         heroTag: 'transaction-$transactionId',
          //       );
          //     },
          //   ),
          // ],
        ),

        // Budgets Routes
        GoRoute(
          path: '/budgets',
          builder: (context, state) => const BudgetsPage(),
          routes: [
            GoRoute(
              path: ':budgetId',
              builder: (context, state) {
                final budgetId = state.pathParameters['budgetId']!;
                final budget = state.extra as Budget?;

                return BudgetDetailsPage(
                  budget: budget ??
                      Budget(
                        id: budgetId,
                        name: '',
                        limitAmount: 0,
                      ),
                );
              },
            ),
          ],
        ),

        // Settings Routes (without accounts)
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'preferences',
              builder: (context, state) => const PreferencesSettingsPage(),
            ),
            GoRoute(
              path: 'about',
              builder: (context, state) => const AboutPage(),
            ),
            GoRoute(
              path: 'export',
              builder: (context, state) => const ExportDataPage(),
            ),
          ],
        ),

        // Subscription Route
        GoRoute(
          path: '/subscription',
          builder: (context, state) => PremiumWidget(),
        ),
      ],
    ),
  ],
);

// Helper function to parse TransactionFilters from query parameters
TransactionFilters _parseFilters(Map<String, String> params) {
  return TransactionFilters(
    minDate:
        params['minDate'] != null ? DateTime.parse(params['minDate']!) : null,
    maxDate:
        params['maxDate'] != null ? DateTime.parse(params['maxDate']!) : null,
    categories: params['categories']?.split(','),
    accountsIDs: params['accounts']?.split(','),
    tagsIDs: params['tags']?.split(','),
    searchValue: params['search'],
  );
}

// Updated route helper class
class AppRoutes {
  // Account routes
  static String accounts() => '/accounts';
  static String account(String id, {Account? account}) => '/accounts/$id';
  static String accountTransactions(String id, {TransactionFilters? filters}) {
    final uri = Uri(
      path: '/accounts/$id/transactions',
      queryParameters: _filtersToQueryParams(filters),
    );
    return uri.toString();
  }

  // Stats routes with category support
  static String statsCategory(String categoryId,
      {TransactionFilters? filters}) {
    final queryParams = _filtersToQueryParams(filters);
    queryParams?['categoryId'] = categoryId;

    final uri = Uri(
      path: '/stats/category',
      queryParameters: queryParams,
    );
    return uri.toString();
  }

  // Budget routes with transactions and tags
  static String budgetTransactions(String budgetId,
      {TransactionFilters? filters}) {
    final uri = Uri(
      path: '/budgets/$budgetId/transactions',
      queryParameters: _filtersToQueryParams(filters),
    );
    return uri.toString();
  }

  // Helper method to convert filters to query parameters
  static Map<String, String>? _filtersToQueryParams(
      TransactionFilters? filters) {
    if (filters == null) return null;

    return {
      if (filters.minDate != null)
        'minDate': filters.minDate!.toIso8601String(),
      if (filters.maxDate != null)
        'maxDate': filters.maxDate!.toIso8601String(),
      if (filters.categories != null)
        'categories': filters.categories!.join(','),
      if (filters.accountsIDs != null)
        'accounts': filters.accountsIDs!.join(','),
      if (filters.tagsIDs != null) 'tags': filters.tagsIDs!.join(','),
      if (filters.searchValue != null) 'search': filters.searchValue!,
    };
  }
}
