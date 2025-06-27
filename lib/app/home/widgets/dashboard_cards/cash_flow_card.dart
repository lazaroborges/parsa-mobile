import 'package:flutter/material.dart';
import 'package:parsa/app/stats/widgets/income_expense_comparason.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';

class CashFlowCard extends StatelessWidget {
  final DatePeriodState dateRangeService;

  const CashFlowCard({super.key, required this.dateRangeService});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: CardWithHeader(
        title: t.stats.cash_flow,
        bodyPadding: EdgeInsets.zero,
        body: IncomeExpenseComparason(
          startDate: dateRangeService.startDate,
          endDate: dateRangeService.endDate,
        ),
        onHeaderButtonClick: () {
          tabsPageKey.currentState?.navigateToStatsTab(2);
        },
      ),
    );
  }
}
