// lib/app/stats/widgets/daily_cash_flow_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/database/services/currency/currency_service.dart';
import 'package:parsa/core/extensions/lists.extensions.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/theme.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/ui_number_formatter.dart';
import 'package:parsa/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:rxdart/rxdart.dart';

class DailyCashFlowChartDataItem {
  List<double> income;
  List<double> expense;
  List<String> labels;

  DailyCashFlowChartDataItem({
    required this.income,
    required this.expense,
    required this.labels,
  });
}

class DailyCashFlowChart extends StatelessWidget {
  const DailyCashFlowChart({
    super.key,
    required this.filters,
    required this.dateRange,
  });

  final TransactionFilters filters;
  final DatePeriodState dateRange;

  Stream<DailyCashFlowChartDataItem?> getDailyFlowData() {
    if (dateRange.startDate == null || dateRange.endDate == null) {
      return Stream.value(null);
    }

    final List<Stream<double>> incomeData = [];
    final List<Stream<double>> expenseData = [];
    final List<String> labels = [];

    DateTime currentDay = DateTime(
      dateRange.startDate!.year,
      dateRange.startDate!.month,
      dateRange.startDate!.day,
    );

    // Get daily data for the date range
    while (currentDay.isBefore(dateRange.endDate!)) {
      final nextDay = currentDay.add(const Duration(days: 1));
      
      labels.add(DateFormat.MMMd().format(currentDay));
      
      // Get income data for this day
      incomeData.add(AccountService.instance.getAccountsBalance(
        filters: filters.copyWith(
          transactionTypes: [TransactionType.I]
              .intersectionWithNullable(filters.transactionTypes)
              .toList(),
          minDate: currentDay,
          maxDate: nextDay,
        ),
      ));
      
      // Get expense data for this day (make positive for charting)
      expenseData.add(AccountService.instance.getAccountsBalance(
        filters: filters.copyWith(
          transactionTypes: [TransactionType.E]
              .intersectionWithNullable(filters.transactionTypes)
              .toList(),
          minDate: currentDay,
          maxDate: nextDay,
        ),
      ).map((value) => value.abs()));
      
      currentDay = nextDay;
    }

    // Combine all streams
    return Rx.combineLatest2(
      Rx.combineLatest(incomeData, (values) => values as List<double>),
      Rx.combineLatest(expenseData, (values) => values as List<double>),
      (income, expense) => DailyCashFlowChartDataItem(
        income: income,
        expense: expense,
        labels: labels,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final incomeColor = Color(0xFF4CAF50); // Green for income
    final expenseColor = Color(0xFFF44336); // Red for expense

    return SizedBox(
      height: 300,
      child: StreamBuilder(
        stream: getDailyFlowData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(t.general.empty_warn));
          }

          final chartData = snapshot.data!;
          final ultraLightBorderColor = isAppInLightBrightness(context)
              ? Colors.black12
              : Colors.white12;

          return StreamBuilder(
            stream: CurrencyService.instance.getUserPreferredCurrency(),
            builder: (context, currencySnapshot) {
              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: ultraLightBorderColor,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= chartData.labels.length || value.toInt() < 0) {
                            return const SizedBox.shrink();
                          }
                          // Only show every 3rd label if we have many data points
                          if (chartData.labels.length > 10 && value.toInt() % 3 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData.labels[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            UINumberFormatter.currency(
                              currency: currencySnapshot.data,
                              amountToConvert: value,
                              integerStyle: const TextStyle(fontSize: 10),
                            ).toString(),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isIncome = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${chartData.labels[spot.x.toInt()]}\n',
                            const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: '${isIncome ? t.transaction.types.income(n: 1) : t.transaction.types.expense(n: 1)}: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? incomeColor : expenseColor,
                                ),
                              ),
                              ...UINumberFormatter.currency(
                                currency: currencySnapshot.data,
                                amountToConvert: spot.y,
                                integerStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ).getTextSpanList(context),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    // Income line
                    LineChartBarData(
                      spots: List.generate(
                        chartData.income.length,
                        (i) => FlSpot(i.toDouble(), chartData.income[i]),
                      ),
                      isCurved: true,
                      color: incomeColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: incomeColor.withOpacity(0.2),
                      ),
                    ),
                    // Expense line
                    LineChartBarData(
                      spots: List.generate(
                        chartData.expense.length,
                        (i) => FlSpot(i.toDouble(), chartData.expense[i]),
                      ),
                      isCurved: true,
                      color: expenseColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: expenseColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}