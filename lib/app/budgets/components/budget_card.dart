import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:parsa/app/budgets/budget_details_page.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/models/budget/budget.dart';
import 'package:parsa/core/models/date-utils/period_type.dart';
import 'package:parsa/core/models/date-utils/periodicity.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/animated_progress_bar.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/skeleton.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/i18n/translations.g.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.budget,
    this.isHeader = false,
    this.showDivider = false,
  });

  final Budget budget;
  final bool isHeader;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontWeight: FontWeight.w600);
    final labelStyle = Theme.of(context).textTheme.bodyMedium;
    final appColors = AppColors.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: appColors.shadowColorLight,
            blurRadius: 8,
            offset: const Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isHeader
              ? null
              : () => RouteUtils.pushRoute(
                  context, BudgetDetailsPage(budget: budget)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROW 1: Title with periodicity and budget type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with periodicity
                    Expanded(
                      flex: 4,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: budget.name,
                              style: titleStyle,
                            ),
                            TextSpan(
                              text: " - ",
                              style: titleStyle.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            TextSpan(
                              text: budget.intervalPeriod != null
                                  ? _getPeriodicityText(
                                      budget.intervalPeriod!, context)
                                  : _formatDateRange(
                                      budget.currentDateRange.start,
                                      budget.currentDateRange.end),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Budget type chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: budget.intervalPeriod != null
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        budget.intervalPeriod != null ? 'Recorrente' : 'Único',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: budget.intervalPeriod != null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ROW 2: Budget status indicator
                _buildBudgetStatusIndicator(context, labelStyle),

                const SizedBox(height: 8),

                // ROW 3: Progress bar and values
                StreamBuilder<double>(
                  stream: budget.currentValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }

                    final currentValue = snapshot.data!;
                    final remainingAmount = budget.limitAmount - currentValue;
                    final percentage = currentValue / budget.limitAmount;
                    final isOverBudget = currentValue > budget.limitAmount;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar
                        AnimatedProgressBar(
                          width: 10, // Slightly increased height
                          radius: 16, // Increased radius for MD3 style
                          value: percentage > 1 ? 1 : percentage,
                          color: percentage > 1
                              ? appColors.danger
                              : Theme.of(context).colorScheme.primary,
                        ),

                        const SizedBox(height: 8),

                        // Current/total values and remaining amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Current / total value
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gasto",
                                  style: labelStyle,
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    style: labelStyle,
                                    children: [
                                      WidgetSpan(
                                        child: CurrencyDisplayer(
                                          amountToConvert: currentValue,
                                          showDecimals: false,
                                          integerStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isOverBudget
                                                ? appColors.danger
                                                : null,
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' / ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: CurrencyDisplayer(
                                          amountToConvert: budget.limitAmount,
                                          showDecimals: false,
                                          integerStyle: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Remaining amount or overspent
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isOverBudget
                                      ? "Passou"
                                      : (remainingAmount == 0
                                          ? "Restou"
                                          : (budget.daysToTheEnd < 0 &&
                                                  remainingAmount > 0
                                              ? "Economizou"
                                              : "Restam")),
                                  style: labelStyle,
                                ),
                                const SizedBox(height: 4),
                                CurrencyDisplayer(
                                  amountToConvert: isOverBudget
                                      ? remainingAmount.abs()
                                      : remainingAmount,
                                  showDecimals: false,
                                  integerStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isOverBudget
                                        ? appColors.danger
                                        : (budget.daysToTheEnd < 0 &&
                                                remainingAmount > 0
                                            ? appColors.success
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                // if (isHeader && budget.isActiveBudget) ...[
                //   const SizedBox(height: 16),
                //   Divider(
                //     height: 1,
                //     thickness: 0.5,
                //     color:
                //         Theme.of(context).colorScheme.outline.withOpacity(0.2),
                //   ),
                //   const SizedBox(height: 16),
                //   StreamBuilder(
                //     stream: CurrencyService.instance.getUserPreferredCurrency(),
                //     builder: (context, snapshot) {
                //       return StreamBuilder(
                //         stream: budget.currentValue,
                //         builder: (context, budgetCurrentValue) {
                //           // Calculate remaining amount first
                //           final remaining = budget.limitAmount -
                //               (budgetCurrentValue.data ?? 0);

                //           // Add guard check to prevent division by zero
                //           final dailyAmount = remaining > 0
                //               ? (budget.daysToTheEnd > 0
                //                   ? remaining / budget.daysToTheEnd
                //                   : remaining) // If days to end is 0, use the full remaining amount
                //               : 0.0;

                //           return Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Flexible(
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Text(
                //                       "Você pode gastar ",
                //                       style: Theme.of(context)
                //                           .textTheme
                //                           .bodyMedium!
                //                           .copyWith(
                //                             color: Theme.of(context)
                //                                 .colorScheme
                //                                 .onSurfaceVariant,
                //                           ),
                //                     ),
                //                     CurrencyDisplayer(
                //                       amountToConvert: dailyAmount,
                //                       showDecimals: false,
                //                       integerStyle: TextStyle(
                //                         fontWeight: FontWeight.w400,
                //                         color: Theme.of(context)
                //                             .colorScheme
                //                             .onSurfaceVariant,
                //                       ),
                //                     ),
                //                     Text(
                //                       " por dia nos próximos ${budget.daysToTheEnd} dias",
                //                       style: Theme.of(context)
                //                           .textTheme
                //                           .bodyMedium!
                //                           .copyWith(
                //                             color: Theme.of(context)
                //                                 .colorScheme
                //                                 .onSurfaceVariant,
                //                           ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ],
                //           );
                //         },
                //       );
                //     },
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the budget status indicator
  Widget _buildBudgetStatusIndicator(BuildContext context, TextStyle? style) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final appColors = AppColors.of(context);
    final statusStyle = Theme.of(context).textTheme.bodyMedium;

    if (budget.daysToTheEnd < 0) {
      // Orçamento concluído
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: appColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Orçamento concluído',
            style: statusStyle!.copyWith(
              color: appColors.success,
            ),
          ),
        ],
      );
    } else if (budget.isActiveBudget) {
      // Orçamento ativo - mostrar dias restantes
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            "Restam ${budget.daysToTheEnd} dias",
            style: statusStyle!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    } else if (budget.isPastBudget) {
      // Orçamento concluído
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: appColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Orçamento concluído',
            style: statusStyle!.copyWith(
              color: appColors.success,
            ),
          ),
        ],
      );
    } else if (budget.isFutureBudget) {
      // Orçamento não iniciado
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.update_rounded,
            size: 14,
            color: Colors.blue.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            'Orçamento não iniciado',
            style: statusStyle!.copyWith(
              color: Colors.blue.shade800,
            ),
          ),
        ],
      );
    }

    // Fallback
    return const SizedBox.shrink();
  }

  String _getPeriodicityText(Periodicity periodicity, BuildContext context) {
    final t = Translations.of(context);
    switch (periodicity) {
      case Periodicity.day:
        return t.general.time.all.diary;
      case Periodicity.week:
        return t.general.time.all.weekly;
      case Periodicity.month:
        return t.general.time.all.monthly;
      case Periodicity.year:
        return t.general.time.all.annually;
      default:
        return t.general.time.periodicity.no_repeat;
    }
  }

  // Helper method to format date range in a more compact way
  String _formatDateRange(DateTime start, DateTime end) {
    final dateFormat = DateFormat('dd/MM/yy');

    // If start and end dates are the same, display just one date
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return dateFormat.format(start);
    }

    return "${dateFormat.format(start)} - ${dateFormat.format(end)}";
  }
}
