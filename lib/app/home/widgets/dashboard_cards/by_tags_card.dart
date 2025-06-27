import 'package:flutter/material.dart';
import 'package:parsa/app/stats/widgets/movements_distribution/tags_stats.dart';
import 'package:parsa/app/tags/tag_list.page.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/presentation/widgets/card_with_header.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/i18n/translations.g.dart';

class ByTagsCard extends StatelessWidget {
  final DatePeriodState dateRangeService;
  const ByTagsCard({super.key, required this.dateRangeService});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: CardWithHeader(
        title: t.stats.by_tags,
        body: TagStats(
          filters: TransactionFilters(
            minDate: dateRangeService.startDate,
            maxDate: dateRangeService.endDate,
          ),
        ),
        onHeaderButtonClick: () => RouteUtils.pushRoute(
          context,
          const TagListPage(),
        ),
      ),
    );
  }
}
