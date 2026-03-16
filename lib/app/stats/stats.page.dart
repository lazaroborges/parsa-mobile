import 'package:flutter/material.dart';
import 'package:parsa/app/stats/widgets/balance_bar_chart.dart';
import 'package:parsa/app/stats/widgets/finance_health_details.dart';
import 'package:parsa/app/stats/widgets/fund_evolution_line_chart.dart';
import 'package:parsa/app/stats/widgets/income_expense_comparason.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/tags_stats.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/dates/segmented_calendar_button.dart';
import 'package:parsa/core/presentation/widgets/filter_row_indicator.dart';
import 'package:parsa/core/presentation/widgets/persistent_footer_button.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/filter_sheet_modal.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';

import '../../core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/database/services/forecast/forecast_mode_service.dart';
import 'package:parsa/core/database/services/forecast/forecast_transaction_service.dart';
import 'package:parsa/core/models/forecast/forecasted_transaction.dart';
import 'package:parsa/core/presentation/widgets/forecast/recurrency_type_badge.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/forecast/forecast_empty_state.dart';
import 'package:parsa/core/models/forecast/recurrency_type.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({
    super.key,
    this.initialIndex = 0,
    this.filters = const TransactionFilters(),
    required this.dateRangeService,
  });

  final int initialIndex;

  final TransactionFilters filters;
  final DatePeriodState dateRangeService;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with RouteAware {
  final accountService = AccountService.instance;

  late TransactionFilters filters;
  late DatePeriodState dateRangeService;
  bool _isStateInitialized = false;

  @override
  void initState() {
    super.initState();
    filters = widget.filters;
    dateRangeService = widget.dateRangeService;
    _initializeStateAsync();
  }

  Future<void> _initializeStateAsync() async {
    final prefs = SharedPreferencesAsync.instance;
    final startDay = await prefs.getStartOfMonth();
    final startWeek = await prefs.getStartOfWeek();

    if (mounted) {
      setState(() {
        dateRangeService = DatePeriodState(
          datePeriod: widget.dateRangeService.datePeriod,
          periodModifier: widget.dateRangeService.periodModifier,
          startOfMonthDay: startDay,
          startOfWeek: startWeek,
        );
        _isStateInitialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshPreferences();
  }

  Future<void> _refreshPreferences() async {
    final prefs = SharedPreferencesAsync.instance;
    final startDay = await prefs.getStartOfMonth();
    final startWeek = await prefs.getStartOfWeek();

    bool needsUpdate = dateRangeService.startOfMonthDay != startDay ||
        dateRangeService.startOfWeek != startWeek;

    if (mounted && needsUpdate) {
      setState(() {
        dateRangeService = dateRangeService.copyWith(
          startOfMonthDay: startDay,
          startOfWeek: startWeek,
        );
      });
    }
  }

  Widget buildContainerWithPadding(
    List<Widget> children, {
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    if (!_isStateInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text(t.stats.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<bool>(
      stream: ForecastModeService.instance.forecastModeStream,
      initialData: ForecastModeService.instance.isInForecastMode,
      builder: (context, forecastSnapshot) {
        if (forecastSnapshot.data == true) {
          return _buildForecastStats(context, t);
        }
        return _buildRealStats(context, t);
      },
    );
  }

  Widget _buildForecastStats(BuildContext context, Translations t) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights - Previsao'),
      ),
      body: StreamBuilder<List<ForecastedTransaction>>(
        stream: ForecastTransactionService.instance.getForecasts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final forecasts = snapshot.data!;
          if (forecasts.isEmpty) {
            return const ForecastEmptyState();
          }

          final expenses = forecasts
              .where((f) => f.type == TransactionType.E)
              .toList();
          final income = forecasts
              .where((f) => f.type == TransactionType.I)
              .toList();

          final totalExpenses = expenses.fold<double>(
              0, (prev, f) => prev + f.forecastAmount);
          final totalIncome = income.fold<double>(
              0, (prev, f) => prev + f.forecastAmount);

          // Group expenses by category
          final expenseByCategory = <String, double>{};
          for (final f in expenses) {
            final key = f.displayName();
            expenseByCategory[key] =
                (expenseByCategory[key] ?? 0) + f.forecastAmount.abs();
          }
          final sortedExpenses = expenseByCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                CardWithHeader(
                  title: 'Resumo da Previsao',
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _forecastStatRow(
                          context,
                          'Receita prevista',
                          totalIncome,
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _forecastStatRow(
                          context,
                          'Despesa prevista',
                          totalExpenses,
                          Colors.red,
                        ),
                        const Divider(height: 16),
                        _forecastStatRow(
                          context,
                          'Saldo previsto',
                          totalIncome + totalExpenses,
                          (totalIncome + totalExpenses) >= 0
                              ? Colors.green
                              : Colors.red,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Expense distribution
                CardWithHeader(
                  title: 'Distribuicao de Despesas',
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: sortedExpenses.map((entry) {
                        final percentage = totalExpenses != 0
                            ? (entry.value / totalExpenses.abs() * 100)
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.key,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recurrency breakdown
                CardWithHeader(
                  title: 'Por Tipo de Recorrencia',
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _recurrencyRow(
                          context,
                          forecasts,
                          'recurrent_fixed',
                          'Fixo',
                        ),
                        const SizedBox(height: 8),
                        _recurrencyRow(
                          context,
                          forecasts,
                          'recurrent_variable',
                          'Variavel',
                        ),
                        const SizedBox(height: 8),
                        _recurrencyRow(
                          context,
                          forecasts,
                          'irregular',
                          'Irregular',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _forecastStatRow(
    BuildContext context,
    String label,
    double amount,
    Color color, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        CurrencyDisplayer(
          amountToConvert: amount,
          integerStyle: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _recurrencyRow(
    BuildContext context,
    List<ForecastedTransaction> forecasts,
    String recurrencyTypeName,
    String label,
  ) {
    final matching = forecasts
        .where((f) => f.recurrencyType.name == recurrencyTypeName)
        .toList();
    final total =
        matching.fold<double>(0, (prev, f) => prev + f.forecastAmount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RecurrencyTypeBadge(
              recurrencyType: matching.isNotEmpty
                  ? matching.first.recurrencyType
                  : RecurrencyType.values
                      .firstWhere((e) => e.name == recurrencyTypeName),
            ),
            const SizedBox(width: 8),
            Text('${matching.length} previsoes'),
          ],
        ),
        CurrencyDisplayer(
          amountToConvert: total,
          integerStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRealStats(BuildContext context, Translations t) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.stats.title),
          actions: [
            IconButton(
                onPressed: () async {
                  final modalRes = await openFilterSheetModal(
                    context,
                    FilterSheetModal(
                      preselectedFilter: filters,
                      showDateFilter: false,
                    ),
                  );

                  if (modalRes != null) {
                    setState(() {
                      filters = modalRes;
                    });
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined)),
          ],
          bottom: TabBar(
              tabAlignment: TabAlignment.center,
              tabs: [
                Tab(text: t.stats.distribution),
                Tab(text: t.categories.subcategories),
                Tab(text: t.stats.cash_flow),
                Tab(text: t.financial_health.display),
                Tab(text: t.stats.balance_evolution),
              ],
              isScrollable: true),
        ),
        persistentFooterButtons: [
          PersistentFooterButton(
            child: SegmentedCalendarButton(
              initialDatePeriodService: dateRangeService,
              onChanged: (value) {
                setState(() {
                  dateRangeService = value.copyWith(
                    startOfMonthDay: dateRangeService.startOfMonthDay,
                    startOfWeek: dateRangeService.startOfWeek,
                  );
                });
              },
            ),
          )
        ],
        body: Column(
          children: [
            if (filters.hasFilter) ...[
              FilterRowIndicator(
                filters: filters,
                onChange: (newFilters) {
                  setState(() {
                    filters = newFilters;
                  });
                },
              ),
              const Divider()
            ],
            Expanded(
              child: TabBarView(children: [
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.by_categories,
                    body: ChartByCategories(
                      datePeriodState: dateRangeService,
                      showList: true,
                      initialSelectedType: TransactionType.E,
                      filters: filters,
                      useSubcategories: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: t.stats.by_tags,
                    body: TagStats(
                      filters: filters.copyWith(
                        minDate: dateRangeService.startDate,
                        maxDate: dateRangeService.endDate,
                      ),
                    ),
                  ),
                ]),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.by_categories,
                    body: ChartByCategories(
                      datePeriodState: dateRangeService,
                      showList: true,
                      initialSelectedType: TransactionType.E,
                      filters: filters,
                      useSubcategories: true,
                    ),
                  ),
                ]),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.cash_flow,
                    body: IncomeExpenseComparason(
                      startDate: dateRangeService.startDate,
                      endDate: dateRangeService.endDate,
                      filters: filters,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CardWithHeader(
                    title: t.stats.by_periods,
                    bodyPadding: const EdgeInsets.only(bottom: 12, top: 16),
                    body: BalanceBarChart(
                      dateRange: dateRangeService,
                      filters: filters,
                    ),
                  )
                ]),
                buildContainerWithPadding(
                  [
                    FinanceHealthDetails(
                      filters: filters.copyWith(
                          minDate: dateRangeService.startDate,
                          maxDate: dateRangeService.endDate),
                    )
                  ],
                ),
                buildContainerWithPadding([
                  CardWithHeader(
                    title: t.stats.balance_evolution,
                    body: FundEvolutionLineChart(
                      showBalanceHeader: true,
                      dateRange: dateRangeService,
                      filters: filters,
                    ),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
