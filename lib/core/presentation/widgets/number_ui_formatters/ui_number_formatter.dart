import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:parsa/core/database/app_db.dart';

enum UINumberFormatterMode { currency, percentage, decimal }

class UINumberFormatter {
  const UINumberFormatter.decimal({
    required this.amountToConvert,
    this.showDecimals = true,
    this.integerStyle = const TextStyle(inherit: true),
    this.decimalsStyle,
  })  : mode = UINumberFormatterMode.decimal,
        currency = null,
        currencyStyle = null;

  const UINumberFormatter.percentage({
    required this.amountToConvert,
    this.showDecimals = true,
    this.integerStyle = const TextStyle(inherit: true),
    this.decimalsStyle,
  })  : mode = UINumberFormatterMode.percentage,
        currency = null,
        currencyStyle = null;

  const UINumberFormatter.currency({
    required this.amountToConvert,
    required this.currency,
    this.showDecimals = true,
    this.integerStyle = const TextStyle(inherit: true),
    this.decimalsStyle,
    this.currencyStyle,
  }) : mode = UINumberFormatterMode.currency;

  /// The amount/number to display
  final double amountToConvert;

  /// The currency of the amount, used to display the currency symbol.
  /// Only defined and used if the `UINumberFormatterMode` of
  /// this Widget is set to `currency`.
  final CurrencyInDB? currency;

  /// Style of the text that corresponds to the integer part of the number to be displayed
  final TextStyle integerStyle;

  /// Style of the text that corresponds to the integer part of the number to be displayed.
  /// If not defined, we will try to use a less prominent style than the one used in the integer
  /// part of the number
  final TextStyle? decimalsStyle;

  /// Style of the text that corresponds to the currency symbol. By default will be
  /// the same as the `integerStyle`. This property is only defined and
  /// used if the `UINumberFormatterMode` of this Widget is set to `currency`.
  final TextStyle? currencyStyle;

  final bool showDecimals;

  final UINumberFormatterMode mode;

  List<TextSpan> getTextSpanList(BuildContext context) {
    final String decimalSep =
        numberFormatSymbols[Intl.defaultLocale?.replaceAll('-', '_') ?? 'en']
            ?.DECIMAL_SEP ?? '.';

    final valueFontSize = (integerStyle.fontSize ??
            DefaultTextStyle.of(context).style.fontSize) ??
        16;

    // Ensure currency style has normal weight
    final normalizedCurrencyStyle = TextStyle(
      fontSize: valueFontSize,
      fontWeight: FontWeight.normal,
      color: (currencyStyle ?? integerStyle).color,
    );

    final computedDecimalStyles = decimalsStyle ??
        integerStyle.copyWith(
          fontWeight: FontWeight.w300,
          fontSize: valueFontSize > 12.25
              ? max(valueFontSize * 0.75, 12.25)
              : valueFontSize,
        );

    List<String> parts = [];
    bool isNegative = amountToConvert < 0;
    double absAmount = amountToConvert.abs();

    if (mode == UINumberFormatterMode.currency) {
      // Remove the decimal separator from the symbol, otherwise the parts won't be splitted correctly
      final String symbolWithoutDecSep =
          currency!.symbol.replaceAll(decimalSep, '');

      final String formattedAmount = NumberFormat.currency(
              decimalDigits: showDecimals ? 2 : 0, symbol: symbolWithoutDecSep)
          .format(absAmount);

      // Get the decimal and the integer part, and restore the original symbol
      parts = formattedAmount
          .split(decimalSep)
          .map((e) => e.replaceAll(symbolWithoutDecSep, currency!.symbol))
          .toList();
    } else if (mode == UINumberFormatterMode.percentage) {
      final String formattedAmount = NumberFormat.decimalPercentPattern(
              decimalDigits: showDecimals ? 2 : 0)
          .format(amountToConvert);

      parts = formattedAmount.split(decimalSep).toList();
    } else if (mode == UINumberFormatterMode.decimal) {
      final String formattedAmount =
          NumberFormat.decimalPatternDigits(decimalDigits: showDecimals ? 2 : 0)
              .format(amountToConvert);

      parts = formattedAmount.split(decimalSep).toList();
    }

    return [
      // Currency symbol
      if (mode == UINumberFormatterMode.currency &&
          parts[0].contains(currency!.symbol))
        TextSpan(
          text: '${currency!.symbol}${isNegative ? '' : '\u200A'}',
          style: normalizedCurrencyStyle,
        ),

      // Minus sign if negative
      if (mode == UINumberFormatterMode.currency && isNegative)
        TextSpan(
          text: '-',
          style: normalizedCurrencyStyle,
        ),

      // Integer part
      TextSpan(
          text: parts[0].replaceAll(currency?.symbol ?? '', '').trim(),
          style: integerStyle),

      // Decimal separator
      if (showDecimals && parts.length > 1)
        TextSpan(text: decimalSep, style: integerStyle),

      // Decimal part
      if (showDecimals && parts.length > 1)
        TextSpan(
          text: parts[1].replaceAll(currency?.symbol ?? '', ''),
          style: computedDecimalStyles,
        ),
    ];
  }

  Text getTextWidget(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: integerStyle,
        children: getTextSpanList(context),
      ),
    );
  }
}
