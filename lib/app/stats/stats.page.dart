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
    final useWorking = await prefs.getStartOfMonthWorkingDaysOnly();
    final startWeek = await prefs.getStartOfWeek();

    if (mounted) {
      setState(() {
        dateRangeService = DatePeriodState(
          datePeriod: widget.dateRangeService.datePeriod,
          periodModifier: widget.dateRangeService.periodModifier,
          startOfMonthDay: startDay,
          useWorkingDays: useWorking,
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
    final useWorking = await prefs.getStartOfMonthWorkingDaysOnly();
    final startWeek = await prefs.getStartOfWeek();

    bool needsUpdate = dateRangeService.startOfMonthDay != startDay ||
        dateRangeService.useWorkingDays != useWorking ||
        dateRangeService.startOfWeek != startWeek;

    if (mounted && needsUpdate) {
      setState(() {
        dateRangeService = dateRangeService.copyWith(
          startOfMonthDay: startDay,
          useWorkingDays: useWorking,
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
                    useWorkingDays: dateRangeService.useWorkingDays,
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
