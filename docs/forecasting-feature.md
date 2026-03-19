# Forecasting Feature — Implementation Notes

**Branch:** `feature/forecasting`
**Phase:** 1 — UI Toggle + Full Replacement
**Date:** 2026-03-16

---

## Overview

Adds a forecast mode toggle that lets users switch between their actual financial data and a projected view of future finances. When toggled, the app's accent color shifts from blue to amber, and all main pages (Dashboard, Transactions, Stats) swap their data source to show forecasted transactions.

---

## Architecture

### ForecastModeService (singleton)

**File:** `lib/core/database/services/forecast/forecast_mode_service.dart`

Controls forecast mode globally via two `BehaviorSubject` streams:

- `forecastModeStream` (`BehaviorSubject<bool>`) — all listening widgets rebuild when mode changes
- `themeStream` (`BehaviorSubject<ThemeData>`) — `MaterialApp` rebuilds with the forecast (amber) or real (blue) theme

Persists the last mode to `SharedPreferences` so it survives app restarts. Accepts the user's real `ColorScheme` and `accentColor` via `setRealTheme()` (called from `MaterialAppContainer`) so it can correctly restore the user's theme when exiting forecast mode.

**Pattern:** Follows `PrivateModeService`.

### ForecastTransactionService (singleton)

**File:** `lib/core/database/services/forecast/forecast_transaction_service.dart`

Provides reactive streams of `ForecastedTransaction` objects with filtering, counting, and grouping. For Phase 1, seeds mock data from real accounts and categories via `seedMockData()` (called once from `TabsPage._initializeData()`).

Key methods:
- `getForecasts(...)` — filtered stream of forecasts
- `countForecasts(...)` — stream of count + value sum
- `getForecastTotals(month, type)` — monthly income/expense totals
- `getForecastById(id)` — single forecast lookup
- `getForecastsByCategory(type, month)` — grouped by category name

**Phase 2+:** Replace mock data with `fetchFromServer()` that syncs from the backend API. The Drift table and queries are already defined (see below) and will be wired when the API is ready.

### ForecastedTransaction Model

**File:** `lib/core/models/forecast/forecasted_transaction.dart`

Standalone Dart class (not Drift-generated for Phase 1). Fields match the backend `forecast_transactions` table spec:

| Field | Type | Notes |
|-------|------|-------|
| `id` | String | PK |
| `recurrencyPatternId` | String? | FK to recurrency_patterns |
| `type` | TransactionType | E or I only (never T) |
| `recurrencyType` | RecurrencyType | `recurrent_fixed`, `recurrent_variable`, `irregular` |
| `forecastAmount` | double | Point estimate |
| `forecastLow` / `forecastHigh` | double? | Confidence bounds |
| `forecastDate` | DateTime? | Specific day (fixed only) |
| `forecastMonth` | DateTime | 1st of target month |
| `cousin` | int? | Counterparty ID for similar transactions |
| `categoryId` / `accountId` | String | FKs resolved to `Category` / `Account` objects |
| `parentCategoryName` | String? | For irregular envelopes without a category |

### RecurrencyType Enum

**File:** `lib/core/models/forecast/recurrency_type.dart`

Three values with display names and badge colors:
- `recurrent_fixed` — "Fixo" (blue)
- `recurrent_variable` — "Variavel" (orange)
- `irregular` — "Irregular" (grey)

---

## Drift Schema (for Phase 2+)

The table and queries are defined but not yet consumed by the service layer (Phase 1 uses in-memory mock data).

**Table:** `forecastTransactions` in `lib/core/database/sql/initial/tables.drift`

**Queries** in `lib/core/database/sql/queries/select-full-data.drift`:
- `getForecastTransactionsWithFullData` — JOINs with accounts, currencies, categories
- `countForecastTransactions` — aggregate count + sum

After modifying these files, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## UI Components

### Nav Bar Toggle

**Placement:** `lib/app/layout/tabs.dart` — integrated into the `NavigationBar` between Stats and Settings

- Real mode: nav item labeled "Previsao" with trending up icon
- Forecast mode: nav item labeled "Real" with teal accent color
- Tapping toggles forecast mode (does not navigate to a page)
- Fires `forecast_mode_toggle` Firebase Analytics event on tap

### RecurrencyTypeBadge

**File:** `lib/core/presentation/widgets/forecast/recurrency_type_badge.dart`

Colored chip displayed on list tiles and detail pages. Supports `small` variant for list tiles.

### ForecastTransactionListTile

**File:** `lib/app/transactions/widgets/forecast_transaction_list_tile.dart`

Displays: category icon + name, forecast amount (colored by type), recurrency badge, account + month subtitle, optional confidence band text. Navigates to `ForecastTransactionDetailsPage` on tap.

### ForecastTransactionListComponent

**File:** `lib/app/transactions/widgets/forecast_transaction_list.dart`

Paginated list with date group separators. Mirrors `TransactionListComponent` patterns (infinite scroll, StreamBuilder, empty state).

### ForecastTransactionDetailsPage

**File:** `lib/app/transactions/forecast_transaction_details.page.dart`

Read-only detail page showing:
- Header with icon, name, amount, confidence band, recurrency badge
- Info table: predicted amount, confidence range, type, category, account, date/month
- **"Transacoes Similares" CardWithHeader** — uses `cousinId` to query `TransactionService` (real transactions) for historical counterparty data

### ForecastEmptyState

**File:** `lib/core/presentation/widgets/forecast/forecast_empty_state.dart`

Informational card: "Previsoes serao geradas quando houver historico suficiente de transacoes."

---

## Page Adaptations

Pages **reuse existing components** — forecast data is converted to `MoneyTransaction` via `ForecastedTransaction.toMoneyTransaction()` and piped through the same widgets.

### Dashboard (`lib/app/home/dashboard.page.dart`)

No separate forecast view — the dashboard always shows the real dashboard. The theme color shift communicates forecast mode.

### Transactions (`lib/app/transactions/transactions.page.dart`)

Forecast mode uses the same `TransactionListComponent` via its `transactionsStream` parameter, passing `ForecastTransactionService.instance.getTransactions()`. No FAB in forecast mode.

### Stats (`lib/app/stats/stats.page.dart`)

No separate forecast view — the stats page always shows the real stats. The theme color shift communicates forecast mode. (Phase 2 will wire forecast data into the existing stat widgets.)

---

## Theme Swap

**Mechanism:** `ForecastModeService` owns a `BehaviorSubject<ThemeData>` stream. `main.dart` wraps `MaterialApp` in a `StreamBuilder<ThemeData>` listening to this stream.

**What changes in forecast mode:**
- `colorScheme.primary` → teal (`0xFF0D9488`)
- All M3 components that derive from primary (FAB, AppBar, nav highlights, pills)
- Floating pill fills with forecast accent

**What stays the same:**
- Surface/background colors, typography (Nunito), layout structure
- `danger`/`success` colors, brand colors

---

## Files Changed

### New Files (7)
| File | Purpose |
|------|---------|
| `lib/core/models/forecast/recurrency_type.dart` | RecurrencyType enum |
| `lib/core/models/forecast/forecasted_transaction.dart` | ForecastedTransaction model + `toMoneyTransaction()` converter |
| `lib/core/database/services/forecast/forecast_mode_service.dart` | Mode toggle + theme service (teal accent) |
| `lib/core/database/services/forecast/forecast_transaction_service.dart` | Forecast data service with mock data + `getTransactions()` returning MoneyTransaction streams |
| `lib/core/presentation/widgets/forecast/forecast_mode_pill.dart` | Toggle pill (unused in nav bar approach, kept for potential reuse) |
| `lib/core/presentation/widgets/forecast/recurrency_type_badge.dart` | Colored type chip |
| `lib/core/presentation/widgets/forecast/forecast_empty_state.dart` | Empty state widget |

### Modified Files (7)
| File | Change |
|------|--------|
| `lib/main.dart` | StreamBuilder for reactive theme, ForecastModeService init + setRealTheme |
| `lib/app/layout/tabs.dart` | Nav bar forecast toggle, mock data seeding |
| `lib/app/transactions/transactions.page.dart` | Forecast mode uses TransactionListComponent with transactionsStream |
| `lib/app/transactions/widgets/transaction_list.dart` | Added optional `transactionsStream` parameter |
| `lib/core/routes/destinations.dart` | Added forecast destination between Stats and Settings |
| `lib/core/database/sql/initial/tables.drift` | `forecastTransactions` table definition |
| `lib/core/database/sql/queries/select-full-data.drift` | Forecast queries |

---

## Testing Checklist

1. **Toggle:** Tap floating pill → accent color shifts across all pages → tap again to return
2. **Transactions list:** Forecast mode shows forecasted transactions with recurrency badges. FAB hidden. Search works.
3. **Transaction details:** Tap forecast → detail page shows amount, confidence band, badge. "Transacoes Similares" loads real transactions via cousinId.
4. **Stats:** Forecast mode shows distribution, subcategories, recurrency breakdown.
5. **Dashboard:** Forecast mode shows summary cards and forecast list.
6. **Theme:** Amber applies to FAB, AppBar, nav highlights, pill. Switching back restores blue.
7. **Persistence:** Kill and reopen → last forecast mode state restored.
8. **Analytics:** `forecast_mode_toggle` event fires on pill tap.
9. **Empty state:** Toggle with no forecast data → informational message appears.

---

## Phase 2+ Roadmap

- Wire `ForecastTransactionService` to Drift queries after running `build_runner`
- Implement `fetchFromServer()` when backend API is ready
- Mid-month blending: settled actuals + remaining forecasts
- Budget vs forecast comparisons on dashboard
- User adjustments, accept/dismiss, feedback loop to backend
