import 'package:flutter/material.dart';
import 'package:parsa/core/database/app_db.dart';
import 'package:parsa/core/extensions/color.extensions.dart';
import 'package:parsa/core/models/supported-icon/icon_displayer.dart';
import 'package:parsa/core/models/supported-icon/supported_icon.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/services/supported_icon/supported_icon_service.dart';
import 'package:parsa/i18n/translations.g.dart';

enum AccountType {
  /// A normal type of account The default type
  normal, //Legacy of Monekin Code - This is the value for Checking Account/Conta Corrente.

  credit,

  /// This type of accounts can not have transactions. You only can add and withdraw money from it from other accounts

  saving,

  wallet;

  IconData get icon {
    if (this == normal) {
      return Icons.account_balance;
    } else if (this == saving) {
      return Icons.savings;
    }
    if (this == credit) {
      return Icons.credit_card;
    }
    if (this == wallet) {
      return Icons.wallet;
    }
    return Icons.account_circle;
  }

  String title(BuildContext context) {
    final t = Translations.of(context);
    if (this == normal) {
      return t.account.types.normal;
    } else if (this == saving) {
      return t.account.types.saving;
    }
    if (this == credit) {
      return t.account.types.credit;
    }
    if (this == wallet) {
      return t.account.types.wallet;
    }

    return '';
  }

  String description(BuildContext context) {
    final t = Translations.of(context);

    if (this == normal) {
      return t.account.types.normal_descr;
    } else if (this == saving) {
      return t.account.types.saving_descr;
    }
    if (this == credit) {
      return t.account.types.credit_descr;
    }
    if (this == wallet) {
      return t.account.types.wallet_descr;
    }

    return '';
  }
}

class Account extends AccountInDB {
  Account({
    required super.id,
    required super.name,
    required super.iniValue,
    required super.date,
    required super.type,
    required super.displayOrder,
    required super.iconId,
    required this.currency,
    required super.balance,
    required super.lastUpdateTime,
    required super.connectorID,
    required super.isOpenFinance,
    super.closingDate,
    super.description,
    super.iban,
    super.swift,
    super.color,
  }) : super(currencyId: currency.code);

  /// Currency of all the transactions of this account. When you change this currency all transactions in this account
  /// will have the new currency but their amount/value will remain the same.
  CurrencyInDB currency;

  SupportedIcon get icon => SupportedIconService.instance.getIconByID(iconId);

  bool get isClosed => closingDate != null;

  Color getComputedColor(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    return color != null
        ? ColorHex.get(color!)
        : isLightMode
            ? AppColors.of(context).primary
            : AppColors.of(context).primaryContainer;
  }

  IconDisplayer displayIcon(
    BuildContext context, {
    double size = 24,
    double? padding,
    double outlineWidth = 4,
    bool isOutline = false,
    void Function()? onTap,
  }) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;

    return IconDisplayer(
      supportedIcon: icon,
      mainColor: getComputedColor(context).lighten(isLightMode ? 0 : 0.82),
      secondaryColor: getComputedColor(context).lighten(isLightMode ? 0.82 : 0),
      displayMode: IconDisplayMode.polygon,
      size: size,
      borderRadius: 20,
      outlineWidth: outlineWidth,
      isOutline: isOutline,
      padding: padding,
      onTap: onTap,
    );
  }

  static Account fromDB(AccountInDB account, CurrencyInDB currency) => Account(
        id: account.id,
        currency: currency,
        iniValue: account.iniValue,
        date: account.date,
        displayOrder: account.displayOrder,
        description: account.description,
        iban: account.iban,
        swift: account.swift,
        name: account.name,
        iconId: account.iconId,
        closingDate: account.closingDate,
        type: account.type,
        color: account.color,
        balance: account.balance, // Add this line
        lastUpdateTime: account.lastUpdateTime,
        connectorID: account.connectorID,
        isOpenFinance: account.isOpenFinance,
      );
}

class ApiAccount {
  final String accountId;
  final String bankName;
  final String accountType;
  final String number;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int profile;
  final double iniValue;
  final String connectorId;
  final String primaryColor;
  final double? balance;
  final String iconId;
  final bool isOpenFinance;
  final DateTime? closedAt;
  final int order;

  ApiAccount({
    required this.accountId,
    required this.bankName,
    required this.accountType,
    required this.iniValue,
    required this.number,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
    required this.connectorId,
    required this.primaryColor,
    required this.iconId,
    this.balance,
    required this.isOpenFinance,
    this.closedAt,
    required this.order,
  });

  factory ApiAccount.fromJson(Map<String, dynamic> json) {
    return ApiAccount(
      accountId: json['accountId'] ??
          'unknown-account', // Fallback for missing accountId
      bankName:
          json['bank_name'] ?? 'Unknown Bank', // Fallback for missing bank name
      accountType:
          json['account_type'] ?? 'normal', // Default to 'normal' if missing
      number: json['number'] ?? '', // Handle null number
      iniValue: json['initial_value'] != null
          ? double.tryParse(json['initial_value'].toString()) ?? 0.0
          : 0.0, // Safely parse iniValue
      name: json['name'] ?? 'Parsa', // Fallback for missing name
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // Default to now if missing
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(), // Default to now if missing
      profile: json['profile'] ?? 0, // Default to 0 if missing
      iconId: json['connector_id'] ?? '1', // Fallback for missing iconId
      connectorId:
          json['connector_id'] ?? '1', // Fallback for missing connectorId
      primaryColor:
          json['primary_color'] ?? '1194F6', // Default to black if missing
      balance: json['balance'] != null
          ? double.tryParse(json['balance'].toString())
          : null, // Safely parse balance
      isOpenFinance:
          json['isOpenFinance'] ?? false, // Default to false if missing
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null, // Safely parse closedAt
      order: json['order'] ?? 90, // Default to 0 if missing
    );
  }
}
