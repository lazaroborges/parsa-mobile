import 'package:flutter/material.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/chart_by_categories.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';

class ByCategoriesCard extends StatelessWidget {
  final DatePeriodState dateRangeService;
  const ByCategoriesCard({super.key, required this.dateRangeService});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: CardWithHeader(
          title: t.stats.by_categories,
          body: ChartByCategories(datePeriodState: dateRangeService),
          onHeaderButtonClick: () {
            tabsPageKey.currentState?.navigateToStatsTab(0);
          }),
    );
  }
}
