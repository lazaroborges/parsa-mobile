import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
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
    final subtitleStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(fontWeight: FontWeight.w300);

    return Column(
      children: [
        // Add divider above card (instead of below)
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: Colors.grey.withOpacity(0.3),
          ),
        InkWell(
          onTap: isHeader
              ? null
              : () => RouteUtils.pushRoute(
                  context, BudgetDetailsPage(budget: budget)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ROW 1: Título e periodicidade
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título e periodicidade
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: titleStyle,
                          children: [
                            TextSpan(text: budget.name),
                            TextSpan(
                              text: budget.intervalPeriod != null
                                  ? " - ${_getPeriodicityText(budget.intervalPeriod!, context)}"
                                  : " - ${t.general.time.periodicity.no_repeat}",
                              style: titleStyle.copyWith(
                                fontWeight: FontWeight.w300,
                                fontSize: titleStyle.fontSize! * 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ROW 2: Dias restantes (com ícone)
                _buildRemainingDaysIndicator(context, subtitleStyle),

                const SizedBox(height: 8),

                // ROW 3 & 4: Barra de progresso e valores
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
                        // ROW 3: Barra de progresso com porcentagem no final
                        Stack(
                          children: [
                            // Barra de progresso
                            AnimatedProgressBar(
                              width: 8, // Reduced height
                              radius: 12, // Reduced radius
                              value: percentage > 1 ? 1 : percentage,
                              color: percentage > 1
                                  ? AppColors.of(context).danger
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            // Porcentagem no final da barra
                            Positioned(
                              right: 0,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  "${(percentage * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: isOverBudget
                                        ? AppColors.of(context).danger
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ROW 4: Valores atuais/totais e valor restante
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Valor atual / valor total
                            RichText(
                              text: TextSpan(
                                style: subtitleStyle,
                                children: [
                                  TextSpan(
                                    text: NumberFormat.currency(
                                      symbol: 'R\$',
                                      decimalDigits: 0,
                                    ).format(currentValue),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isOverBudget
                                          ? AppColors.of(context).danger
                                          : null,
                                    ),
                                  ),
                                  const TextSpan(text: '/'),
                                  TextSpan(
                                    text: NumberFormat.currency(
                                      symbol: 'R\$',
                                      decimalDigits: 0,
                                    ).format(budget.limitAmount),
                                  ),
                                ],
                              ),
                            ),

                            // Valor restante ou estouro
                            Row(
                              children: [
                                Text(
                                  isOverBudget ? "Passou " : "Restam ",
                                  style: subtitleStyle,
                                ),
                                CurrencyDisplayer(
                                  amountToConvert: isOverBudget
                                      ? remainingAmount.abs()
                                      : remainingAmount,
                                  showDecimals: false,
                                  integerStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isOverBudget
                                        ? AppColors.of(context).danger
                                        : Theme.of(context).colorScheme.primary,
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

                if (isHeader && budget.isActiveBudget) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder(
                        stream:
                            CurrencyService.instance.getUserPreferredCurrency(),
                        builder: (context, snapshot) {
                          return StreamBuilder(
                              stream: budget.currentValue,
                              builder: (context, budgetCurrentValue) {
                                final dailyAmount = (budget.limitAmount -
                                            (budgetCurrentValue.data ?? 0)) >
                                        0
                                    ? (budget.limitAmount -
                                            (budgetCurrentValue.data ?? 0)) /
                                        budget.daysToTheEnd
                                    : 0.0;

                                return Text(
                                  t.budgets.details.expend_diary_left(
                                    dailyAmount: NumberFormat.currency(
                                      symbol: snapshot.data?.symbol ?? '',
                                      decimalDigits: 0,
                                    ).format(dailyAmount),
                                    remainingDays: budget.daysToTheEnd,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w300),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build the remaining days indicator (simplified)
  Widget _buildRemainingDaysIndicator(BuildContext context, TextStyle style) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    if (budget.daysToTheEnd < 0) {
      // Período encerrado
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 14,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            'Período Encerrado',
            style: style.copyWith(
              color: Colors.amber.shade800,
            ),
          ),
        ],
      );
    } else if (budget.isActiveBudget) {
      // Dias restantes para orçamento ativo
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
            style: style.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    } else if (budget.isPastBudget) {
      // Orçamento passado
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 14,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            '${budget.daysToTheEnd.abs()} ${t.budgets.since_expiration}',
            style: style.copyWith(
              color: Colors.amber.shade800,
            ),
          ),
        ],
      );
    } else if (budget.isFutureBudget) {
      // Orçamento futuro
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
            '${budget.daysToTheStart} ${t.budgets.days_to_start}',
            style: style.copyWith(
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
}
