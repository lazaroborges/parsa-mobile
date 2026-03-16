import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/category/category_service.dart';
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/core/models/forecast/recurrency_type.dart';
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

  bool _isSeeded = false;

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

  /// Seed mock data for Phase 1 development
  Future<void> seedMockData() async {
    if (_isSeeded) return;

    try {
      final accounts = await AccountService.instance.getAccounts().first;
      final allCategories =
          await CategoryService.instance.getMainCategories().first;

      if (accounts.isEmpty) {
        _forecastsController.add([]);
        _isSeeded = true;
        return;
      }

      final now = DateTime.now();
      final forecastMonth = DateTime(now.year, now.month + 1, 1);
      final defaultAccount = accounts.first;

      // Split categories by type
      final expenseCategories =
          allCategories.where((c) => c.type.isExpense).toList();
      final incomeCategories =
          allCategories.where((c) => c.type.isIncome).toList();

      final mockForecasts = <ForecastedTransaction>[];
      int idCounter = 1;

      // Generate expense forecasts
      for (var i = 0; i < expenseCategories.length && i < 8; i++) {
        final cat = expenseCategories[i];
        final account =
            accounts.length > 1 ? accounts[i % accounts.length] : defaultAccount;
        final isFixed = i < 3;
        final isVariable = i >= 3 && i < 6;

        final amount = -(100.0 + (i * 150.0));
        // For expenses (negative): low is less negative (smaller loss), high is more negative (larger loss)
        final low = amount * 0.85;  // e.g. -250 * 0.85 = -212.5 (less negative = lower bound)
        final high = amount * 1.15; // e.g. -250 * 1.15 = -287.5 (more negative = upper bound)

        mockForecasts.add(ForecastedTransaction(
          id: 'forecast_${idCounter++}',
          recurrencyPatternId: 'pattern_$i',
          type: TransactionType.E,
          recurrencyType: isFixed
              ? RecurrencyType.recurrent_fixed
              : isVariable
                  ? RecurrencyType.recurrent_variable
                  : RecurrencyType.irregular,
          forecastAmount: amount,
          forecastLow: isFixed ? null : low,
          forecastHigh: isFixed ? null : high,
          forecastDate:
              isFixed ? DateTime(forecastMonth.year, forecastMonth.month, 5 + i * 5) : null,
          forecastMonth: forecastMonth,
          cousin: i + 1,
          categoryId: cat.id,
          accountId: account.id,
          category: cat,
          account: account,
        ));
      }

      // Generate income forecasts
      for (var i = 0; i < incomeCategories.length && i < 3; i++) {
        final cat = incomeCategories[i];
        final amount = 2000.0 + (i * 1000.0);

        mockForecasts.add(ForecastedTransaction(
          id: 'forecast_${idCounter++}',
          recurrencyPatternId: 'pattern_income_$i',
          type: TransactionType.I,
          recurrencyType: i == 0
              ? RecurrencyType.recurrent_fixed
              : RecurrencyType.recurrent_variable,
          forecastAmount: amount,
          forecastLow: i == 0 ? null : amount * 0.9,
          forecastHigh: i == 0 ? null : amount * 1.1,
          forecastDate: i == 0
              ? DateTime(forecastMonth.year, forecastMonth.month, 5)
              : null,
          forecastMonth: forecastMonth,
          cousin: 100 + i,
          categoryId: cat.id,
          accountId: defaultAccount.id,
          category: cat,
          account: defaultAccount,
        ));
      }

      // Add an irregular expense without category (envelope pattern)
      mockForecasts.add(ForecastedTransaction(
        id: 'forecast_${idCounter++}',
        type: TransactionType.E,
        recurrencyType: RecurrencyType.irregular,
        forecastAmount: -350.0,
        forecastLow: -500.0,
        forecastHigh: -200.0,
        forecastMonth: forecastMonth,
        accountId: defaultAccount.id,
        parentCategoryName: 'Outros gastos',
        account: defaultAccount,
      ));

      _forecastsController.add(mockForecasts);
      _isSeeded = true;
    } catch (e) {
      print('Error seeding mock forecast data: $e');
      _forecastsController.add([]);
    }
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
          .where((f) => f.account != null)
          .map((f) => f.toMoneyTransaction())
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
