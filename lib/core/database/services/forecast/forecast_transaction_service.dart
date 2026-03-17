import 'package:parsa/core/api/fetch_user_forecasts.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:rxdart/rxdart.dart';

class ForecastCountResult {
  final int numberOfRes;
  final double valueSum;

  ForecastCountResult({required this.numberOfRes, required this.valueSum});
}

class ForecastTransactionService {
  ForecastTransactionService._();
  static final ForecastTransactionService instance =
      ForecastTransactionService._();

  final _forecastsController =
      BehaviorSubject<List<ForecastedTransaction>>.seeded([]);

  /// Fetch forecasts from API for a given month and load into the stream.
  /// [forecastMonth] in YYYY-MM format (e.g., "2026-03").
  Future<void> fetchAndLoadForecasts(String forecastMonth) async {
    print('[ForecastService] fetchAndLoadForecasts called for $forecastMonth');
    try {
      final forecasts = await fetchUserForecasts(forecastMonth);
      print('[ForecastService] Fetched ${forecasts.length} forecasts, resolving relationships...');

      // Resolve relationships (account, category) for each forecast
      final accounts = await AccountService.instance.getAccounts().first;
      if (accounts.isEmpty) {
        print('[ForecastService] No accounts found, skipping forecast loading');
        _forecastsController.add([]);
        return;
      }

      final allCategories =
          await CategoryService.instance.getCategories().first;

      for (final forecast in forecasts) {
        // Resolve account
        forecast.account = accounts
            .where((a) => a.id == forecast.accountId)
            .firstOrNull;

        // Resolve category by name (API returns category name string)
        if (forecast.categoryName != null) {
          forecast.category = allCategories
              .where((c) => c.name == forecast.categoryName)
              .firstOrNull;
          if (forecast.category != null) {
            forecast.categoryId = forecast.category!.id;
          }
        }
      }

      final withAccounts = forecasts.where((f) => f.account != null).length;
      final withCategories = forecasts.where((f) => f.category != null).length;
      print('[ForecastService] Loaded ${forecasts.length} forecasts ($withAccounts with accounts, $withCategories with categories)');
      for (final f in forecasts.where((f) => f.account == null)) {
        print('[ForecastService] UNMATCHED accountId: ${f.accountId}');
      }
      if (accounts.isNotEmpty) {
        print('[ForecastService] Available account IDs: ${accounts.map((a) => a.id).toList()}');
      }
      _forecastsController.add(forecasts);
    } catch (e, stackTrace) {
      print('Error fetching forecasts from API: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Reload forecasts for a specific month. Called when user navigates months in forecast mode.
  Future<void> loadMonth(DateTime month) async {
    final monthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    await fetchAndLoadForecasts(monthStr);
  }

  /// Get forecasts with optional filtering
  Stream<List<ForecastedTransaction>> getForecasts({
    DateTime? minDate,
    DateTime? maxDate,
    List<TransactionType>? transactionTypes,
    Iterable<String>? accountsIDs,
    Iterable<String>? categories,
    String? searchValue,
    int? limit,
    int? cousin,
  }) {
    return _forecastsController.stream.map((forecasts) {
      var filtered = forecasts.toList();

      if (minDate != null) {
        filtered =
            filtered.where((f) => !f.displayDate.isBefore(minDate)).toList();
      }
      if (maxDate != null) {
        filtered =
            filtered.where((f) => !f.displayDate.isAfter(maxDate)).toList();
      }
      if (transactionTypes != null && transactionTypes.isNotEmpty) {
        filtered =
            filtered.where((f) => transactionTypes.contains(f.type)).toList();
      }
      if (accountsIDs != null && accountsIDs.isNotEmpty) {
        filtered =
            filtered.where((f) => accountsIDs.contains(f.accountId)).toList();
      }
      if (categories != null && categories.isNotEmpty) {
        filtered =
            filtered.where((f) => categories.contains(f.categoryId)).toList();
      }
      if (searchValue != null && searchValue.isNotEmpty) {
        final query = searchValue.toLowerCase();
        filtered = filtered.where((f) {
          return f.displayName().toLowerCase().contains(query) ||
              (f.parentCategoryName?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
      if (cousin != null) {
        filtered = filtered.where((f) => f.cousin == cousin).toList();
      }
      if (limit != null && limit > 0) {
        filtered = filtered.take(limit).toList();
      }

      return filtered;
    });
  }

  /// Count forecasts and sum values
  Stream<ForecastCountResult> countForecasts({
    DateTime? minDate,
    DateTime? maxDate,
    List<TransactionType>? transactionTypes,
    Iterable<String>? accountsIDs,
    Iterable<String>? categories,
    String? searchValue,
  }) {
    return getForecasts(
      minDate: minDate,
      maxDate: maxDate,
      transactionTypes: transactionTypes,
      accountsIDs: accountsIDs,
      categories: categories,
      searchValue: searchValue,
    ).map((forecasts) {
      final sum =
          forecasts.fold<double>(0, (prev, f) => prev + f.forecastAmount);
      return ForecastCountResult(numberOfRes: forecasts.length, valueSum: sum);
    });
  }

  /// Get forecast totals for a month grouped by type
  Stream<double> getForecastTotals({
    required DateTime month,
    required TransactionType type,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return getForecasts(
      minDate: start,
      maxDate: end,
      transactionTypes: [type],
    ).map((forecasts) {
      return forecasts.fold<double>(0, (prev, f) => prev + f.forecastAmount);
    });
  }

  /// Get a single forecast by ID
  Stream<ForecastedTransaction?> getForecastById(String id) {
    return _forecastsController.stream.map((forecasts) {
      return forecasts.where((f) => f.id == id).firstOrNull;
    });
  }

  /// Get forecasts as MoneyTransaction objects for reuse with existing UI components
  Stream<List<MoneyTransaction>> getTransactions({
    DateTime? minDate,
    DateTime? maxDate,
    List<TransactionType>? transactionTypes,
    Iterable<String>? accountsIDs,
    Iterable<String>? categories,
    String? searchValue,
    int? limit,
  }) {
    return getForecasts(
      minDate: minDate,
      maxDate: maxDate,
      transactionTypes: transactionTypes,
      accountsIDs: accountsIDs,
      categories: categories,
      searchValue: searchValue,
      limit: limit,
    ).map((forecasts) {
      return forecasts
          .map((f) => f.toMoneyTransaction())
          .whereType<MoneyTransaction>()
          .toList();
    });
  }

  /// Check if there are any forecasts available
  bool get hasForecasts => _forecastsController.value.isNotEmpty;

  /// Get forecasts grouped by category for charts
  Stream<Map<String, double>> getForecastsByCategory({
    required TransactionType type,
    DateTime? month,
  }) {
    return _forecastsController.stream.map((forecasts) {
      final filtered = forecasts.where((f) {
        if (f.type != type) return false;
        if (month != null) {
          return f.forecastMonth.year == month.year &&
              f.forecastMonth.month == month.month;
        }
        return true;
      });

      final result = <String, double>{};
      for (final f in filtered) {
        final key = f.displayName();
        result[key] = (result[key] ?? 0) + f.forecastAmount;
      }
      return result;
    });
  }
}
