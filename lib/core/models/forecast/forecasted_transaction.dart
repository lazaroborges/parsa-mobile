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
  final String? cousinName;
  String? categoryId;
  final String? categoryName;
  final String accountId;
  final String? parentCategoryName;
  final String? description;

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
    this.cousinName,
    this.categoryId,
    this.categoryName,
    required this.accountId,
    this.parentCategoryName,
    this.description,
    this.category,
    this.account,
  });

  String displayName() {
    return description ??
        category?.name ??
        categoryName ??
        parentCategoryName ??
        cousinName ??
        'Previsao';
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

  /// Effective display date: last day of the forecast month
  DateTime get displayDate {
    final lastDay = DateTime(forecastMonth.year, forecastMonth.month + 1, 0);
    return forecastDate ?? lastDay;
  }

  /// Confidence band text (e.g. "R$ 380 – R$ 420")
  String? get confidenceBandText {
    if (forecastLow != null && forecastHigh != null) {
      return '${forecastLow!.toStringAsFixed(2)} – ${forecastHigh!.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Convert to MoneyTransaction so existing UI components can render this forecast.
  MoneyTransaction? toMoneyTransaction() {
    if (account == null) return null;
    final cat = category;
    final acc = account!;

    return MoneyTransaction(
      id: id,
      date: displayDate,
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

  static double? _negate(double? v) => v != null ? -v : null;

  factory ForecastedTransaction.fromJson(Map<String, dynamic> json) {
    final isCredit = json['type'] == 'CREDIT';
    final rawAmount = (json['forecastAmount'] as num).toDouble();
    // API returns positive amounts; app expects negative for expenses
    final amount = isCredit ? rawAmount : -rawAmount;

    return ForecastedTransaction(
      id: json['id'] as String,
      recurrencyPatternId: json['recurrencyPatternId'] != null
          ? json['recurrencyPatternId'].toString()
          : null,
      type: isCredit ? TransactionType.I : TransactionType.E,
      recurrencyType: RecurrencyType.fromString(
          json['recurrencyType'] as String? ?? 'irregular'),
      forecastAmount: amount,
      forecastLow: isCredit
          ? (json['forecastLow'] as num?)?.toDouble()
          : _negate((json['forecastHigh'] as num?)?.toDouble()),
      forecastHigh: isCredit
          ? (json['forecastHigh'] as num?)?.toDouble()
          : _negate((json['forecastLow'] as num?)?.toDouble()),
      forecastDate: json['forecastDate'] != null
          ? DateTime.parse(json['forecastDate'] as String)
          : null,
      forecastMonth: DateTime.parse(json['forecastMonth'] as String),
      cousin: json['cousin'] as int?,
      cousinName: json['cousinName'] as String?,
      categoryName: json['category'] as String?,
      accountId: json['accountId'] as String,
      description: json['description'] as String?,
    );
  }
}
