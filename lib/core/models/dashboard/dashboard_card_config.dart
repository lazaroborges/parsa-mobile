import 'package:flutter/material.dart';

enum DashboardCardKey {
  accounts,
  creditCards,
  lastTransactions,
  byCategories,
  cashFlow,
  byTags,
  budgets,
}

extension DashboardCardKeyExtension on DashboardCardKey {
  String get title {
    switch (this) {
      case DashboardCardKey.accounts:
        return 'Contas';
      case DashboardCardKey.creditCards:
        return 'Cartões de Crédito';
      case DashboardCardKey.lastTransactions:
        return 'Últimas Transações';
      case DashboardCardKey.byCategories:
        return 'Gastos por Categoria';
      case DashboardCardKey.cashFlow:
        return 'Fluxo de Caixa';
      case DashboardCardKey.byTags:
        return 'Gastos por Tags';
      case DashboardCardKey.budgets:
        return 'Orçamentos';
    }
  }

  IconData get icon {
    switch (this) {
      case DashboardCardKey.accounts:
        return Icons.account_balance_wallet_outlined;
      case DashboardCardKey.creditCards:
        return Icons.credit_card_outlined;
      case DashboardCardKey.lastTransactions:
        return Icons.receipt_long_outlined;
      case DashboardCardKey.byCategories:
        return Icons.pie_chart_outline;
      case DashboardCardKey.cashFlow:
        return Icons.show_chart_outlined;
      case DashboardCardKey.byTags:
        return Icons.tag_outlined;
      case DashboardCardKey.budgets:
        return Icons.savings_outlined;
    }
  }
}

class DashboardCardConfig {
  final DashboardCardKey key;
  bool enabled;
  int order;

  DashboardCardConfig({
    required this.key,
    this.enabled = true,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key.name,
      'enabled': enabled,
      'order': order,
    };
  }

  factory DashboardCardConfig.fromJson(Map<String, dynamic> json) {
    return DashboardCardConfig(
      key: DashboardCardKey.values.firstWhere((e) => e.name == json['key']),
      enabled: json['enabled'] as bool,
      order: json['order'] as int,
    );
  }
}
