import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/all_accounts.page.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/app/budgets/budgets.page.dart';
import 'package:parsa/app/budgets/budget_details.page.dart';
import 'package:parsa/app/transactions/transactions.page.dart';
import 'package:parsa/app/transactions/transaction_details.page.dart';
import 'package:parsa/app/settings/settings.page.dart';
import 'package:parsa/app/settings/preferences_settings.page.dart';
import 'package:parsa/app/settings/about.page.dart';
import 'package:parsa/app/settings/export.page.dart';
import 'package:parsa/app/settings/subscriptions/subscription.page.dart';
import 'package:parsa/app/tags/tag_list.page.dart';
import 'package:parsa/app/tags/tag_form_page.dart';
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/database/services/budget/budget_service.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/transaction/transaction_service.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/core/database/services/tags/tags_service.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/models/tags/tag.dart';
import 'package:parsa/app/stats/stats.page.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/database/services/category/category_service.dart';

class MaterialAppRoutes {
  /// Route generator function for MaterialApp to handle bRoth static and dynamic routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == null) return null;

    if (kDebugMode) {
      print('Generating route for: ${settings.name}');
    }

    final uri = Uri.parse(settings.name ?? '/');
    final pathSegments = uri.pathSegments;

    // Helper function to check route pattern
    bool routeMatches(List<String> pattern) {
      if (pathSegments.length != pattern.length) return false;

      for (int i = 0; i < pattern.length; i++) {
        if (pattern[i].startsWith(':')) continue; // Skip parameter segments
        if (pattern[i] != pathSegments[i]) return false;
      }

      return true;
    }

    // Extract query parameters
    final queryParams = settings.arguments as Map<String, dynamic>? ?? {};

    // Route matching and generation

    // Budget routes
    if (routeMatches(['budgets'])) {
      return MaterialPageRoute(builder: (_) => const BudgetsPage());
    }

    // Handle direct budget ID paths
    if (pathSegments.length == 2 && pathSegments[0] == 'budgets') {
      final budgetId = pathSegments[1];
      print('Navigating to budget details for ID: $budgetId');

      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<Budget?>(
          future: BudgetService.instance.getBudgetById(budgetId).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final budget = snapshot.data;
            return BudgetDetailsPage(
              budget: budget ??
                  Budget(
                    id: budgetId,
                    name: '',
                    limitAmount: 0,
                  ),
            );
          },
        );
      });
    }

    // Tag routes
    if (routeMatches(['tags'])) {
      return MaterialPageRoute(builder: (_) => const TagListPage());
    }

    // Handle direct tag ID paths
    if (pathSegments.length == 2 && pathSegments[0] == 'tags') {
      final tagId = pathSegments[1];
      print('Navigating to tag details for ID: $tagId');

      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<TagInDB?>(
          future: TagService.instance.getTagById(tagId).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final tag = snapshot.data;
            if (tag == null) {
              // Fallback to tags list if tag not found
              return const TagListPage();
            }

            // Convert TagInDB to Tag for TagFormPage
            return TagFormPage(tag: Tag.fromTagInDB(tag));
          },
        );
      });
    }

    // Account routes
    if (routeMatches(['accounts'])) {
      return MaterialPageRoute(builder: (_) => const AllAccountsPage());
    }

    // Handle direct account ID paths
    if (pathSegments.length == 2 && pathSegments[0] == 'accounts') {
      final accountId = pathSegments[1];
      print('Navigating to account details for ID: $accountId');

      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<Account?>(
          future: AccountService.instance.getAccountById(accountId).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final account = snapshot.data;
            if (account == null) {
              // Fallback to accounts list if account not found
              return const AllAccountsPage();
            }

            return AccountDetailsPage(
              account: account,
              accountIconHeroTag: 'account-$accountId',
            );
          },
        );
      });
    }

    // Transaction routes
    if (routeMatches(['transactions'])) {
      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<List<String>>(
          future: () async {
            debugPrint('[NAV] Transactions route: queryParams = ' +
                queryParams.toString());
            if (queryParams.containsKey('queryParams') &&
                queryParams['queryParams'] is Map<String, String>) {
              final Map<String, String> qp =
                  queryParams['queryParams'] as Map<String, String>;
              List<String> categoryNames = qp['categories']?.split(',') ?? [];
              List<String> categoryIds = [];
              for (final name in categoryNames) {
                if (name.trim().isEmpty) continue;
                final cat = await CategoryService.instance
                    .getCategoryByName(name.trim())
                    .first;
                if (cat != null) categoryIds.add(cat.id);
              }
              return List<String>.from(categoryIds);
            }
            return <String>[];
          }(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            TransactionFilters filters = const TransactionFilters();
            bool validFilters = false;
            if (queryParams.containsKey('queryParams') &&
                queryParams['queryParams'] is Map<String, String>) {
              final Map<String, String> qp =
                  queryParams['queryParams'] as Map<String, String>;
              filters = TransactionFilters(
                minDate: qp['minDate'] != null
                    ? DateTime.tryParse(qp['minDate']!)
                    : null,
                maxDate: qp['maxDate'] != null
                    ? DateTime.tryParse(qp['maxDate']!)
                    : null,
                searchValue: qp['search'],
                accountsIDs: qp['accounts']?.split(','),
                categories: snapshot.data,
                tagsIDs: qp['tags']?.split(','),
              );
              validFilters = qp.isNotEmpty;
              debugPrint('[NAV] Transactions filters constructed: ' +
                  filters.toString());
            }
            if (!validFilters) {
              debugPrint(
                  '[NAV] Transactions: No valid filters, redirecting to plain TransactionsPage');
              return const TransactionsPage();
            }
            return TransactionsPage(filters: filters);
          },
        );
      });
    }

    // Stats routes
    if (routeMatches(['stats'])) {
      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<List<String>>(
          future: () async {
            debugPrint(
                '[NAV] Stats route: queryParams = ' + queryParams.toString());
            if (queryParams.containsKey('queryParams') &&
                queryParams['queryParams'] is Map<String, String>) {
              final Map<String, String> qp =
                  queryParams['queryParams'] as Map<String, String>;
              List<String> categoryNames = qp['categories']?.split(',') ?? [];
              List<String> categoryIds = [];
              for (final name in categoryNames) {
                if (name.trim().isEmpty) continue;
                final cat = await CategoryService.instance
                    .getCategoryByName(name.trim())
                    .first;
                if (cat != null) categoryIds.add(cat.id);
              }
              return List<String>.from(categoryIds);
            }
            return <String>[];
          }(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            TransactionFilters filters = const TransactionFilters();
            bool validFilters = false;
            if (queryParams.containsKey('queryParams') &&
                queryParams['queryParams'] is Map<String, String>) {
              final Map<String, String> qp =
                  queryParams['queryParams'] as Map<String, String>;
              filters = TransactionFilters(
                minDate: qp['minDate'] != null
                    ? DateTime.tryParse(qp['minDate']!)
                    : null,
                maxDate: qp['maxDate'] != null
                    ? DateTime.tryParse(qp['maxDate']!)
                    : null,
                searchValue: qp['search'],
                accountsIDs: qp['accounts']?.split(','),
                categories: snapshot.data,
                tagsIDs: qp['tags']?.split(','),
              );
              validFilters = qp.isNotEmpty;
              debugPrint(
                  '[NAV] Stats filters constructed: ' + filters.toString());
            }
            if (!validFilters) {
              debugPrint(
                  '[NAV] Stats: No valid filters, redirecting to plain StatsPage');
              return StatsPage(
                filters: const TransactionFilters(),
                dateRangeService: const DatePeriodState(),
              );
            }
            return StatsPage(
              filters: filters,
              dateRangeService: const DatePeriodState(),
            );
          },
        );
      });
    }

    // Handle direct transaction ID paths
    if (pathSegments.length == 2 && pathSegments[0] == 'transactions') {
      final transactionId = pathSegments[1];
      print('Navigating to transaction details for ID: $transactionId');

      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<MoneyTransaction?>(
          future: TransactionService.instance
              .getTransactionById(transactionId)
              .first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final transaction = snapshot.data;
            if (transaction == null) {
              // Fallback to transactions list if transaction not found
              return const TransactionsPage();
            }

            return TransactionDetailsPage(
              transaction: transaction,
              heroTag: 'transaction-$transactionId',
              prevPage: const TransactionsPage(),
            );
          },
        );
      });
    }

    // Settings routes
    if (routeMatches(['settings'])) {
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    }

    if (routeMatches(['settings', 'preferences'])) {
      return MaterialPageRoute(builder: (_) => const PreferencesSettingsPage());
    }

    if (routeMatches(['settings', 'about'])) {
      return MaterialPageRoute(builder: (_) => const AboutPage());
    }

    if (routeMatches(['settings', 'export'])) {
      return MaterialPageRoute(builder: (_) => const ExportDataPage());
    }

    // Subscription route
    if (routeMatches(['subscription'])) {
      return MaterialPageRoute(builder: (_) => const PremiumWidget());
    }

    // Default to home route if no match found
    if (pathSegments.isEmpty ||
        (pathSegments.length == 1 && pathSegments[0] == '')) {
      // Handle home route - could redirect to TabsPage or another main page
      return null; // Return null to let MaterialApp use its home property
    }

    // No route found
    print('No route found for ${settings.name}');
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Route ${settings.name} not found'),
        ),
      ),
    );
  }

  /// Helper method to convert route name with parameters to an actual route path
  static String buildRoute(String routePattern, Map<String, String> params) {
    String route = routePattern;

    params.forEach((key, value) {
      route = route.replaceAll(':$key', value);
    });

    return route;
  }
}
