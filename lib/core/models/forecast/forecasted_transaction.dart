import 'package:flutter/material.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/models/category/category.dart';
import 'package:parsa/core/models/forecast/recurrency_type.dart';
import 'package:parsa/core/models/supported-icon/icon_displayer.dart';
import 'package:parsa/core/models/transaction/transaction.dart';
import 'package:parsa/core/models/transaction/transaction_status.enum.dart';
import 'package:parsa/core/models/transaction/transaction_type.enum.dart';

class ForecastedTransaction {
  final String id;
  final String? recurrencyPatternId;
  final TransactionType type;
  final RecurrencyType recurrencyType;
  final double forecastAmount;
  final double? forecastLow;
  final double? forecastHigh;
  final DateTime? forecastDate;
  final DateTime forecastMonth;
  final int? cousin;
  final String? categoryId;
  final String accountId;
  final String? parentCategoryName;

  // Resolved relationships
  Category? category;
  Account? account;

  ForecastedTransaction({
    required this.id,
    this.recurrencyPatternId,
    required this.type,
    required this.recurrencyType,
    required this.forecastAmount,
    this.forecastLow,
    this.forecastHigh,
    this.forecastDate,
    required this.forecastMonth,
    this.cousin,
    this.categoryId,
    required this.accountId,
    this.parentCategoryName,
    this.category,
    this.account,
  });

  String displayName() {
    return category?.name ?? parentCategoryName ?? 'Previsao';
  }

  Color color(BuildContext context) {
    if (category != null) {
      return ColorHex.get(category!.color);
    }
    return type == TransactionType.I ? Colors.green : Colors.red;
  }

  IconDisplayer getDisplayIcon(
    BuildContext context, {
    double size = 22,
    double? padding,
  }) {
    if (category != null) {
      return IconDisplayer.fromCategory(
        context,
        category: category!,
        size: size,
        padding: padding,
        borderRadius: 999999,
      );
    }
    return IconDisplayer(
      mainColor: color(context),
      icon: type == TransactionType.I
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      size: size,
      padding: padding,
      borderRadius: 999999,
    );
  }

  /// Effective display date: forecastDate for fixed, first of forecastMonth otherwise
  DateTime get displayDate => forecastDate ?? forecastMonth;

  /// Confidence band text (e.g. "R$ 380 – R$ 420")
  String? get confidenceBandText {
    if (forecastLow != null && forecastHigh != null) {
      return '${forecastLow!.toStringAsFixed(2)} – ${forecastHigh!.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Convert to MoneyTransaction so existing UI components can render this forecast.
  MoneyTransaction toMoneyTransaction() {
    final cat = category;
    final acc = account!;

    return MoneyTransaction(
      id: id,
      date: forecastDate ?? forecastMonth,
      value: forecastAmount,
      isHidden: false,
      type: type,
      title: displayName(),
      account: acc,
      accountCurrency: acc.currency,
      category: cat,
      currentValueInPreferredCurrency: forecastAmount,
      tags: const [],
      cousin: cousin,
      status: TransactionStatus.pending,
    );
  }

  factory ForecastedTransaction.fromJson(Map<String, dynamic> json) {
    return ForecastedTransaction(
      id: json['id'] as String,
      recurrencyPatternId: json['recurrency_pattern_id'] as String?,
      type: json['type'] == 'CREDIT' ? TransactionType.I : TransactionType.E,
      recurrencyType: RecurrencyType.fromString(
          json['recurrency_type'] as String? ?? 'irregular'),
      forecastAmount: (json['forecast_amount'] as num).toDouble(),
      forecastLow: (json['forecast_low'] as num?)?.toDouble(),
      forecastHigh: (json['forecast_high'] as num?)?.toDouble(),
      forecastDate: json['forecast_date'] != null
          ? DateTime.parse(json['forecast_date'] as String)
          : null,
      forecastMonth: DateTime.parse(json['forecast_month'] as String),
      cousin: json['cousin'] as int?,
      categoryId: json['category_id'] as String?,
      accountId: json['account_id'] as String,
      parentCategoryName: json['parent_category'] as String?,
    );
  }
}
