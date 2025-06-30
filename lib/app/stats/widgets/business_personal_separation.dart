import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:parsa/core/presentation/widgets/number_ui_formatters/ui_number_formatter.dart';
import 'package:parsa/core/presentation/widgets/trending_value.dart';

enum BusinessPersonalType { business, personal }

class BusinessPersonalItem {
  final BusinessPersonalType type;
  final String name;
  final double income;
  final double expenses;
  final double balance;
  final double trend;
  final Color color;
  final int transactionCount;

  BusinessPersonalItem({
    required this.type,
    required this.name,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.trend,
    required this.color,
    required this.transactionCount,
  });

  double get total => income + expenses;
}

class BusinessPersonalSeparation extends StatefulWidget {
  const BusinessPersonalSeparation({super.key});

  @override
  State<BusinessPersonalSeparation> createState() => _BusinessPersonalSeparationState();
}

class _BusinessPersonalSeparationState extends State<BusinessPersonalSeparation> {
  int touchedIndex = -1;
  bool showIncome = true;

  // Dados mockados para demonstração
  List<BusinessPersonalItem> get mockData => [
    BusinessPersonalItem(
      type: BusinessPersonalType.business,
      name: 'Negócio',
      income: 3500.00,
      expenses: 1000.00,
      balance: 2000.00,
      trend: 0.12, // 12% de crescimento
      color: AppColors.of(context).brand,
      transactionCount: 156,
    ),
    BusinessPersonalItem(
      type: BusinessPersonalType.personal,
      name: 'Pessoal',
      income: 8500.00,
      expenses: 6000.00,
      balance: 2500.00,
      trend: -0.05, // -5% (redução)
      color: AppColors.of(context).brandLight,
      transactionCount: 89,
    ),
  ];

  double get totalValue => mockData.map((e) => showIncome ? e.income : e.expenses).fold(0.0, (a, b) => a + b);

  double getPercentage(BusinessPersonalItem item) {
    final value = showIncome ? item.income : item.expenses;
    return totalValue > 0 ? value / totalValue : 0;
  }

  List<PieChartSectionData> showingSections() {
    return mockData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 49.0 : 42.0;
      final percentage = getPercentage(item);

      return PieChartSectionData(
        color: item.color,
        value: percentage,
        title: '',
        radius: radius,
        badgeWidget: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).canvasColor,
            border: Border.all(width: 1.5, color: item.color),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            item.type == BusinessPersonalType.business 
                ? Icons.business_center 
                : Icons.person,
            color: item.color,
            size: 16,
          ),
        ),
        badgePositionPercentageOffset: 0.98,
      );
    }).toList();
  }

  Widget _buildCurrencyText(double amount, {Color? color, double fontSize = 14, FontWeight fontWeight = FontWeight.normal}) {
    return DefaultTextStyle(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      child: CurrencyDisplayer(amountToConvert: amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Segmented Button para alternar entre Receitas e Despesas
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Receitas'),
                icon: Icon(Icons.trending_up),
              ),
              ButtonSegment(
                value: false,
                label: Text('Despesas'),
                icon: Icon(Icons.trending_down),
              ),
            ],
            selected: {showIncome},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                showIncome = newSelection.first;
              });
            },
          ),
        ),

        const SizedBox(height: 16),

        // Gráfico de Pizza
        SizedBox(
          height: 175,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 35,
              sections: showingSections(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Lista de detalhes
        ...mockData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == touchedIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected 
                  ? Border.all(color: item.color, width: 2)
                  : Border.all(color: Colors.grey.withOpacity(0.2)),
              color: isSelected 
                  ? item.color.withOpacity(0.05)
                  : Colors.transparent,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color.withOpacity(0.1),
                ),
                child: Icon(
                  item.type == BusinessPersonalType.business 
                      ? Icons.business_center 
                      : Icons.person,
                  color: item.color,
                  size: 24,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? item.color : null,
                    ),
                  ),
                  _buildCurrencyText(
                    showIncome ? item.income : item.expenses,
                    color: showIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.transactionCount} transações',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TrendingValue(
                            percentage: item.trend,
                            fontSize: 12,
                            decimalDigits: 1,
                          ),
                          const SizedBox(width: 8),
                          UINumberFormatter.percentage(
                            amountToConvert: getPercentage(item),
                            showDecimals: true,
                            integerStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ).getTextWidget(context),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Resumo financeiro
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: item.color.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Receitas', style: TextStyle(fontSize: 10)),
                            _buildCurrencyText(
                              item.income,
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Despesas', style: TextStyle(fontSize: 10)),
                            _buildCurrencyText(
                              item.expenses,
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Saldo', style: TextStyle(fontSize: 10)),
                            _buildCurrencyText(
                              item.balance,
                              color: item.balance >= 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  touchedIndex = touchedIndex == index ? -1 : index;
                });
              },
            ),
          );
        }).toList(),

        const SizedBox(height: 16),

        // Card de resumo geral
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                AppColors.of(context).brand.withOpacity(0.1),
                AppColors.of(context).brandLight.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: AppColors.of(context).brand.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo Geral',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).brand,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Total Receitas', style: TextStyle(fontSize: 12)),
                      _buildCurrencyText(
                        mockData.map((e) => e.income).fold(0.0, (a, b) => a + b),
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Total Despesas', style: TextStyle(fontSize: 12)),
                      _buildCurrencyText(
                        mockData.map((e) => e.expenses).fold(0.0, (a, b) => a + b),
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Saldo Total', style: TextStyle(fontSize: 12)),
                      _buildCurrencyText(
                        mockData.map((e) => e.balance).fold(0.0, (a, b) => a + b),
                        color: mockData.map((e) => e.balance).fold(0.0, (a, b) => a + b) >= 0 
                            ? Colors.green 
                            : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}