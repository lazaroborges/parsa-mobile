# Forecast Stats Page Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Stats page show forecast data when in Forecast Mode instead of reconciled transaction data.

**Architecture:** Each stats widget checks `ForecastModeService.isInForecastMode` and swaps its data source from `TransactionService`/`AccountService` to `ForecastTransactionService`. New helper methods on `ForecastTransactionService` provide balance aggregation. The Finance Health tab is hidden in forecast mode.

**Tech Stack:** Flutter, Drift, RxDart, fl_chart

---

## File Structure

- **Modify:** `lib/core/database/services/forecast/forecast_transaction_service.dart` — add `getAccountsBalance()` stream for income/expense totals
- **Modify:** `lib/app/stats/stats.page.dart` — wrap in `StreamBuilder<bool>` for forecast mode, hide Finance Health tab
- **Modify:** `lib/app/stats/widgets/movements_distribution/chart_by_categories.dart` — swap `TransactionService.getTransactions` for `ForecastTransactionService.getTransactions`
- **Modify:** `lib/app/stats/widgets/income_expense_comparason.dart` — swap `AccountService.getAccountsBalance` for forecast balance stream
- **Modify:** `lib/app/stats/widgets/balance_bar_chart.dart` — swap balance data source
- **Modify:** `lib/app/stats/widgets/fund_evolution_line_chart.dart` — swap to forecast cumulative balance
- **Modify:** `lib/app/stats/widgets/movements_distribution/tags_stats.dart` — swap transaction stream

---

### Task 1: Add balance helper methods to ForecastTransactionService

**Files:**
- Modify: `lib/core/database/services/forecast/forecast_transaction_service.dart`

- [ ] **Step 1: Add `getAccountsBalance` method**

This method sums forecast amounts, optionally filtered by type, accounts, categories, and date range. It mirrors what `AccountService.getAccountsBalance` does but from forecast data.

```dart
/// Get the sum of forecast amounts, optionally filtered.
/// Returns a stream that updates when forecasts change.
Stream<double> getAccountsBalance({
  TransactionFilters? filters,
}) {
  return getForecasts(
    minDate: filters?.minDate,
    maxDate: filters?.maxDate,
    transactionTypes: filters?.transactionTypes,
    accountsIDs: filters?.accountsIDs,
    categories: filters?.categories,
    includeParentCategoriesInSearch:
        filters?.includeParentCategoriesInSearch ?? false,
    searchValue: filters?.searchValue,
  ).map((forecasts) {
    return forecasts.fold<double>(0, (prev, f) => prev + f.forecastAmount);
  });
}
```

Add the import at the top of the file:
```dart
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
```

- [ ] **Step 2: Add `getAccountsMoney` method for cumulative balance at a date**

For the fund evolution chart, we need balance at a specific date. Since forecasts don't have real account balances, we return the cumulative sum of forecasts up to that date.

```dart
/// Get cumulative forecast amount up to a given date.
/// Used by fund_evolution_line_chart in forecast mode.
Stream<double> getAccountsMoney({
  TransactionFilters? filters,
  required DateTime date,
}) {
  return getForecasts(
    maxDate: date,
    transactionTypes: filters?.transactionTypes,
    accountsIDs: filters?.accountsIDs,
    categories: filters?.categories,
    includeParentCategoriesInSearch:
        filters?.includeParentCategoriesInSearch ?? false,
  ).map((forecasts) {
    return forecasts.fold<double>(0, (prev, f) => prev + f.forecastAmount);
  });
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/database/services/forecast/forecast_transaction_service.dart
git commit -m "feat: add balance helper methods to ForecastTransactionService for stats"
```

---

### Task 2: Make StatsPage forecast-aware (hide Finance Health tab)

**Files:**
- Modify: `lib/app/stats/stats.page.dart`

- [ ] **Step 1: Add ForecastModeService import and wrap build in StreamBuilder**

Add import:
```dart
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
```

In `_buildStats`, wrap the `DefaultTabController` in a `StreamBuilder<bool>` listening to `ForecastModeService.instance.forecastModeStream`. Change the tab count and tabs/tab views based on `isForecastMode`:

- When `isForecastMode == true`: 4 tabs (Distribution, Subcategories, Cash Flow, Balance Evolution) — skip Finance Health
- When `isForecastMode == false`: 5 tabs (same as current)

The key change in `_buildStats`:
```dart
return StreamBuilder<bool>(
  stream: ForecastModeService.instance.forecastModeStream,
  initialData: ForecastModeService.instance.isInForecastMode,
  builder: (context, forecastSnapshot) {
    final isForecastMode = forecastSnapshot.data ?? false;
    final tabCount = isForecastMode ? 4 : 5;

    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: tabCount,
      child: Scaffold(
        // ... appBar same as before but tabs list changes:
        // bottom: TabBar(tabs: [...filter out Finance Health when isForecastMode])
        // body: TabBarView(children: [...filter out Finance Health when isForecastMode])
      ),
    );
  },
);
```

Specifically for tabs:
```dart
tabs: [
  Tab(text: t.stats.distribution),
  Tab(text: t.categories.subcategories),
  Tab(text: t.stats.cash_flow),
  if (!isForecastMode) Tab(text: t.financial_health.display),
  Tab(text: t.stats.balance_evolution),
],
```

And for TabBarView children, similarly exclude the `FinanceHealthDetails` widget when in forecast mode.

- [ ] **Step 2: Commit**

```bash
git add lib/app/stats/stats.page.dart
git commit -m "feat: make stats page forecast-aware, hide finance health in forecast mode"
```

---

### Task 3: Adapt ChartByCategories for forecast mode

**Files:**
- Modify: `lib/app/stats/widgets/movements_distribution/chart_by_categories.dart`

- [ ] **Step 1: Add forecast imports and modify getEvolutionData**

Add imports:
```dart
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
```

In `getEvolutionData`, at the beginning, check `ForecastModeService.instance.isInForecastMode`. If true, use `ForecastTransactionService.instance.getTransactions(...)` instead of `TransactionService.instance.getTransactions(...)`:

```dart
final isForecastMode = ForecastModeService.instance.isInForecastMode;

final List<MoneyTransaction> transactions;
final List<MoneyTransaction> previousTransactions;

if (isForecastMode) {
  transactions = await ForecastTransactionService.instance
      .getTransactions(
        transactionTypes: _getTransactionFilters().transactionTypes,
        accountsIDs: _getTransactionFilters().accountsIDs,
        categories: _getTransactionFilters().categories,
        includeParentCategoriesInSearch:
            _getTransactionFilters().includeParentCategoriesInSearch,
        minDate: _getTransactionFilters().minDate,
        maxDate: _getTransactionFilters().maxDate,
        searchValue: _getTransactionFilters().searchValue,
      )
      .first;
  // No previous period data for forecasts
  previousTransactions = [];
} else {
  transactions = await transactionService
      .getTransactions(filters: _getTransactionFilters())
      .first;
  previousTransactions = await transactionService
      .getTransactions(filters: previousPeriodFilters)
      .first;
}
```

The rest of the method (category grouping, trend calculation) works the same since both return `List<MoneyTransaction>`.

- [ ] **Step 2: Commit**

```bash
git add lib/app/stats/widgets/movements_distribution/chart_by_categories.dart
git commit -m "feat: adapt chart_by_categories for forecast mode"
```

---

### Task 4: Adapt IncomeExpenseComparason for forecast mode

**Files:**
- Modify: `lib/app/stats/widgets/income_expense_comparason.dart`

- [ ] **Step 1: Add forecast imports and swap balance streams**

Add imports:
```dart
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
```

Create a helper method to get the right balance stream:

```dart
Stream<double> _getBalanceStream(TransactionFilters f) {
  if (ForecastModeService.instance.isInForecastMode) {
    return ForecastTransactionService.instance.getAccountsBalance(filters: f);
  }
  return AccountService.instance.getAccountsBalance(filters: f);
}
```

Replace the three `AccountService.instance.getAccountsBalance(...)` calls with `_getBalanceStream(...)`.

- [ ] **Step 2: Commit**

```bash
git add lib/app/stats/widgets/income_expense_comparason.dart
git commit -m "feat: adapt income_expense_comparason for forecast mode"
```

---

### Task 5: Adapt BalanceBarChart for forecast mode

**Files:**
- Modify: `lib/app/stats/widgets/balance_bar_chart.dart`

- [ ] **Step 1: Add forecast imports and swap balance streams**

Add imports:
```dart
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
```

In `getDataByPeriods`, replace the `getIncomeData` and `getExpenseData` closures to check forecast mode:

```dart
final isForecastMode = ForecastModeService.instance.isInForecastMode;

getIncomeData(DateTime? startDate, DateTime? endDate) async {
  final f = widget.filters.copyWith(
    transactionTypes: [TransactionType.I]
        .intersectionWithNullable(widget.filters.transactionTypes)
        .toList(),
    minDate: startDate,
    maxDate: endDate,
  );
  if (isForecastMode) {
    return await ForecastTransactionService.instance
        .getAccountsBalance(filters: f)
        .first;
  }
  return await accountService.getAccountsBalance(filters: f).first;
}

getExpenseData(DateTime? startDate, DateTime? endDate) async {
  final f = widget.filters.copyWith(
    transactionTypes: [TransactionType.E]
        .intersectionWithNullable(widget.filters.transactionTypes)
        .toList(),
    minDate: startDate,
    maxDate: endDate,
  );
  if (isForecastMode) {
    return await ForecastTransactionService.instance
        .getAccountsBalance(filters: f)
        .first;
  }
  return await accountService.getAccountsBalance(filters: f).first;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/app/stats/widgets/balance_bar_chart.dart
git commit -m "feat: adapt balance_bar_chart for forecast mode"
```

---

### Task 6: Adapt FundEvolutionLineChart for forecast mode

**Files:**
- Modify: `lib/app/stats/widgets/fund_evolution_line_chart.dart`

- [ ] **Step 1: Add forecast imports and swap data streams**

Add imports:
```dart
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
```

In `getEvolutionData`, swap the `AccountService.instance.getAccountsMoney` call:

```dart
final isForecastMode = ForecastModeService.instance.isInForecastMode;

// In the while loop:
if (isForecastMode) {
  balance.add(ForecastTransactionService.instance
      .getAccountsMoney(filters: filters, date: currentDay));
} else {
  balance.add(AccountService.instance
      .getAccountsMoney(trFilters: filters, date: currentDay));
}
```

For the balance header section (`showBalanceHeader`), when in forecast mode hide the "compared to previous period" `TrendingValue` since we don't have previous forecast data, or show 0. Simplest: wrap the `getAccountsMoneyVariation` StreamBuilder in a check:

```dart
if (!isForecastMode) ...[
  // existing TrendingValue StreamBuilder
]
```

Since `isForecastMode` is needed in the build method (which is a StatelessWidget), read it at the top of `build`:
```dart
final isForecastMode = ForecastModeService.instance.isInForecastMode;
```

- [ ] **Step 2: Commit**

```bash
git add lib/app/stats/widgets/fund_evolution_line_chart.dart
git commit -m "feat: adapt fund_evolution_line_chart for forecast mode"
```

---

### Task 7: Adapt TagStats for forecast mode

**Files:**
- Modify: `lib/app/stats/widgets/movements_distribution/tags_stats.dart`

- [ ] **Step 1: Add forecast imports and swap transaction stream**

Add imports:
```dart
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
```

In `build`, swap the `TransactionService.instance.getTransactions` stream:

```dart
final isForecastMode = ForecastModeService.instance.isInForecastMode;

final transactionStream = isForecastMode
    ? ForecastTransactionService.instance.getTransactions(
        minDate: filters.minDate,
        maxDate: filters.maxDate,
        transactionTypes: filters.transactionTypes,
        accountsIDs: filters.accountsIDs,
        categories: filters.categories,
        includeParentCategoriesInSearch:
            filters.includeParentCategoriesInSearch,
        searchValue: filters.searchValue,
      )
    : TransactionService.instance.getTransactions(filters: filters);
```

Then use `transactionStream` in the `StreamBuilder`. Note: forecast transactions don't have tags, so this tab will likely show "insufficient data" in forecast mode — which is correct behavior.

- [ ] **Step 2: Commit**

```bash
git add lib/app/stats/widgets/movements_distribution/tags_stats.dart
git commit -m "feat: adapt tags_stats for forecast mode"
```

---

### Task 8: Final verification

- [ ] **Step 1: Run flutter analyze**

```bash
cd /Users/lazaro/Documents/old-mac/Documents/flutter/parsa && flutter analyze
```

Fix any lint issues.

- [ ] **Step 2: Test manually**

1. Open app in reconciliation mode → verify Stats page works as before (5 tabs)
2. Switch to Forecast mode → verify Stats page shows 4 tabs (no Finance Health)
3. In Forecast mode, check Distribution tab shows forecast categories
4. Check Cash Flow tab shows forecast income/expense
5. Check Balance Evolution tab shows forecast cumulative data

- [ ] **Step 3: Commit all remaining fixes**
