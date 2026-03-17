# Forecasting API Wiring Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace mock forecast data with real API calls to `GET /api/forecasts/?forecast_month=YYYY-MM`.

**Architecture:** Create a new API fetch function (`fetch_user_forecasts.dart`). Update `ForecastedTransaction.fromJson()` to match the actual API response format (camelCase keys). Replace `seedMockData()` with `fetchAndLoadForecasts()` in the service, remove dead mock code, and wire it into the initialization flow in `tabs.dart`.

**Tech Stack:** Flutter, http package, RxDart BehaviorSubject, existing BackendAuthService for JWT auth.

---

## Key Differences: API Response vs Current `fromJson`

The API returns camelCase keys. The current `fromJson` expects snake_case. Additionally, the API returns:
- `category` as a string name (not an ID)
- `cousinName` as a string (currently unmapped)
- `description` as a string (currently unmapped)
- `forecastMonth` as ISO 8601 datetime `"2026-03-01T00:00:00Z"` (not `YYYY-MM`)
- `recurrencyType` as `"recurrent_fixed"`, `"recurrent_variable"`, or `"irregular"` — matches enum `.name` exactly
- `parentCategoryName` is NOT returned by the API — intentionally left unmapped in new `fromJson`

---

### Task 1: Update `ForecastedTransaction` model to match API response

**Files:**
- Modify: `lib/core/models/forecast/forecasted_transaction.dart`

- [ ] **Step 1: Update fields, constructor, `displayName()`, and `fromJson`**

Add `cousinName`, `categoryName`, `description` fields. Make `categoryId` mutable (needed for post-fetch category resolution in Task 3). Update `displayName()` fallback chain. Replace `fromJson` to map camelCase API keys.

Full updated class (replace entire file):

```dart
import 'package:flutter/material.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/forecast/recurrency_type.dart';
import 'package:parsa/core/models/supported-icon/icon_displayer.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';

class ForecastedTransaction {
  final String id;
  final String? recurrencyPatternId;
  final TransactionType type;
  final RecurrencyType recurrencyType;
  final double forecastAmount;
  final double? forecastLow;
  final double? forecastHigh;
  final DateTime? forecastDate;
  final DateTime forecastMonth;
  final int? cousin;
  final String? cousinName;
  String? categoryId;
  final String? categoryName;
  final String accountId;
  final String? parentCategoryName;
  final String? description;

  // Resolved relationships
  Category? category;
  Account? account;

  ForecastedTransaction({
    required this.id,
    this.recurrencyPatternId,
    required this.type,
    required this.recurrencyType,
    required this.forecastAmount,
    this.forecastLow,
    this.forecastHigh,
    this.forecastDate,
    required this.forecastMonth,
    this.cousin,
    this.cousinName,
    this.categoryId,
    this.categoryName,
    required this.accountId,
    this.parentCategoryName,
    this.description,
    this.category,
    this.account,
  });

  String displayName() {
    return description ??
        category?.name ??
        categoryName ??
        parentCategoryName ??
        cousinName ??
        'Previsao';
  }

  Color color(BuildContext context) {
    if (category != null) {
      return ColorHex.get(category!.color);
    }
    return type == TransactionType.I ? Colors.green : Colors.red;
  }

  IconDisplayer getDisplayIcon(
    BuildContext context, {
    double size = 22,
    double? padding,
  }) {
    if (category != null) {
      return IconDisplayer.fromCategory(
        context,
        category: category!,
        size: size,
        padding: padding,
        borderRadius: 999999,
      );
    }
    return IconDisplayer(
      mainColor: color(context),
      icon: type == TransactionType.I
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      size: size,
      padding: padding,
      borderRadius: 999999,
    );
  }

  DateTime get displayDate => forecastDate ?? forecastMonth;

  String? get confidenceBandText {
    if (forecastLow != null && forecastHigh != null) {
      return '${forecastLow!.toStringAsFixed(2)} – ${forecastHigh!.toStringAsFixed(2)}';
    }
    return null;
  }

  MoneyTransaction toMoneyTransaction() {
    final cat = category;
    final acc = account!;

    return MoneyTransaction(
      id: id,
      date: forecastDate ?? forecastMonth,
      value: forecastAmount,
      isHidden: false,
      type: type,
      title: displayName(),
      account: acc,
      accountCurrency: acc.currency,
      category: cat,
      currentValueInPreferredCurrency: forecastAmount,
      tags: const [],
      cousin: cousin,
      status: TransactionStatus.pending,
    );
  }

  factory ForecastedTransaction.fromJson(Map<String, dynamic> json) {
    return ForecastedTransaction(
      id: json['id'] as String,
      recurrencyPatternId: json['recurrencyPatternId'] != null
          ? json['recurrencyPatternId'].toString()
          : null,
      type: json['type'] == 'CREDIT' ? TransactionType.I : TransactionType.E,
      recurrencyType: RecurrencyType.fromString(
          json['recurrencyType'] as String? ?? 'irregular'),
      forecastAmount: (json['forecastAmount'] as num).toDouble(),
      forecastLow: (json['forecastLow'] as num?)?.toDouble(),
      forecastHigh: (json['forecastHigh'] as num?)?.toDouble(),
      forecastDate: json['forecastDate'] != null
          ? DateTime.parse(json['forecastDate'] as String)
          : null,
      forecastMonth: DateTime.parse(json['forecastMonth'] as String),
      cousin: json['cousin'] as int?,
      cousinName: json['cousinName'] as String?,
      categoryName: json['category'] as String?,
      accountId: json['accountId'] as String,
      description: json['description'] as String?,
    );
  }
}
```

- [ ] **Step 2: Verify the model compiles**

Run: `cd /Users/lazaro/Documents/old-mac/Documents/flutter/parsa && flutter analyze lib/core/models/forecast/forecasted_transaction.dart 2>&1 | head -20`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/models/forecast/forecasted_transaction.dart
git commit -m "feat: update ForecastedTransaction model to match API camelCase response"
```

---

### Task 2: Create API fetch function for forecasts

**Files:**
- Create: `lib/core/api/fetch_user_forecasts.dart`

- [ ] **Step 1: Create `fetch_user_forecasts.dart`**

Create `lib/core/api/fetch_user_forecasts.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/services/auth/backend_auth_service.dart';

/// Fetches forecasts from the API for a given month.
/// [forecastMonth] must be in YYYY-MM format (e.g., "2026-03").
Future<List<ForecastedTransaction>> fetchUserForecasts(String forecastMonth) async {
  final authService = BackendAuthService.instance;
  final token = authService.token;

  if (token == null) {
    throw Exception('No authentication token found');
  }

  final response = await http.get(
    Uri.parse('$apiEndpoint/api/forecasts/?forecast_month=$forecastMonth'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<dynamic> results = jsonResponse['results'] ?? [];
    return results
        .map((json) => ForecastedTransaction.fromJson(json as Map<String, dynamic>))
        .toList();
  } else if (response.statusCode == 401) {
    throw Exception('Authentication failed. Please log in again.');
  } else {
    throw Exception('Failed to load forecasts: ${response.statusCode}');
  }
}
```

- [ ] **Step 2: Verify the file compiles**

Run: `cd /Users/lazaro/Documents/old-mac/Documents/flutter/parsa && flutter analyze lib/core/api/fetch_user_forecasts.dart 2>&1 | head -20`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/api/fetch_user_forecasts.dart
git commit -m "feat: add API fetch function for forecasts"
```

---

### Task 3: Update `ForecastTransactionService` — replace mock with API, clean up dead code

**Files:**
- Modify: `lib/core/database/services/forecast/forecast_transaction_service.dart`

- [ ] **Step 1: Add `fetchAndLoadForecasts()` method, remove `seedMockData()` and `_isSeeded`**

Add import at top:
```dart
import 'package:parsa/core/api/fetch_user_forecasts.dart';
```

Remove:
- The `bool _isSeeded = false;` field
- The entire `seedMockData()` method (~110 lines)

Add new method `fetchAndLoadForecasts()`:

```dart
/// Fetch forecasts from API for a given month and load into the stream.
/// [forecastMonth] in YYYY-MM format (e.g., "2026-03").
Future<void> fetchAndLoadForecasts(String forecastMonth) async {
  try {
    final forecasts = await fetchUserForecasts(forecastMonth);

    // Resolve relationships (account, category) for each forecast
    final accounts = await AccountService.instance.getAccounts().first;
    if (accounts.isEmpty) {
      _forecastsController.add([]);
      return;
    }

    final allCategories = await CategoryService.instance.getCategories().first;

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

    _forecastsController.add(forecasts);
  } catch (e) {
    print('Error fetching forecasts from API: $e');
  }
}

/// Reload forecasts for a specific month. Called when user navigates months in forecast mode.
Future<void> loadMonth(DateTime month) async {
  final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';
  await fetchAndLoadForecasts(monthStr);
}
```

**Key decisions:**
- Uses `getCategories()` (all categories including subcategories) instead of `getMainCategories()` so subcategory names returned by the API can be matched.
- Guards against empty accounts list to avoid null crashes in `toMoneyTransaction()`.
- Removes `_isSeeded` and `seedMockData()` as they are now dead code.

- [ ] **Step 2: Verify it compiles**

Run: `cd /Users/lazaro/Documents/old-mac/Documents/flutter/parsa && flutter analyze lib/core/database/services/forecast/forecast_transaction_service.dart 2>&1 | head -20`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/database/services/forecast/forecast_transaction_service.dart
git commit -m "feat: replace seedMockData with fetchAndLoadForecasts from API"
```

---

### Task 4: Wire forecast API into initialization flow

**Context:** `fetchUserForecasts` depends on accounts being loaded first (for relationship resolution). It should run **after** accounts finish, **in parallel** with transactions. This matches the pattern in `dashboard.page.dart` where transactions also run after accounts.

**Files:**
- Modify: `lib/app/layout/tabs.dart`
- Modify: `lib/app/home/dashboard.page.dart`

- [ ] **Step 1: Remove `seedMockData()` from `_initializeData()` in `tabs.dart`**

In `lib/app/layout/tabs.dart`, remove lines ~124-125:
```dart
// Seed mock forecast data for Phase 1
await ForecastTransactionService.instance.seedMockData();
```

The forecast fetch will be triggered from `dashboard.page.dart` instead, where the accounts→transactions ordering already exists.

- [ ] **Step 2: Add forecast fetch in parallel with transactions in `dashboard.page.dart`**

In `lib/app/home/dashboard.page.dart`, find (~line 236-240):
```dart
      // Finally fetch transactions and budgets
      await Future.wait([
        fetchUserTransactions(null),
        //fetchUserBudgets(context),
      ]);
```

Replace with:
```dart
      // Finally fetch transactions, budgets, and forecasts in parallel
      final now = DateTime.now();
      final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      await Future.wait([
        fetchUserTransactions(null),
        //fetchUserBudgets(context),
        ForecastTransactionService.instance.fetchAndLoadForecasts(currentMonth),
      ]);
```

Add the import at the top of `dashboard.page.dart` if not already present:
```dart
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
```

- [ ] **Step 3: Verify it compiles**

Run: `cd /Users/lazaro/Documents/old-mac/Documents/flutter/parsa && flutter analyze lib/app/layout/tabs.dart lib/app/home/dashboard.page.dart 2>&1 | head -20`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/app/layout/tabs.dart lib/app/home/dashboard.page.dart
git commit -m "feat: wire forecast API in parallel with transactions, after accounts load"
```

---

## Summary of Changes

| File | Action | Purpose |
|------|--------|---------|
| `lib/core/models/forecast/forecasted_transaction.dart` | Modify | Add `cousinName`, `categoryName`, `description` fields; make `categoryId` mutable; update `fromJson` for camelCase API keys; update `displayName()` |
| `lib/core/api/fetch_user_forecasts.dart` | Create | API fetch function for `GET /api/forecasts/?forecast_month=YYYY-MM` |
| `lib/core/database/services/forecast/forecast_transaction_service.dart` | Modify | Add `fetchAndLoadForecasts()` and `loadMonth()`, remove `seedMockData()` and `_isSeeded` |
| `lib/app/layout/tabs.dart` | Modify | Remove `seedMockData()` call |
| `lib/app/home/dashboard.page.dart` | Modify | Add `fetchAndLoadForecasts()` in parallel with `fetchUserTransactions()` |
