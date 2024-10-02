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
  saving;

  IconData get icon {
    if (this == normal) {
      return Icons.wallet;
    } else if (this == saving) {
      return Icons.savings;
    }
    if (this == credit) {
      return Icons.credit_card;
    }

    return Icons.question_mark;
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
  final String connectorId;
  final String primaryColor;
  final double? balance;
  final String iconId;

  ApiAccount({
    required this.accountId,
    required this.bankName,
    required this.accountType,
    required this.number,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
    required this.connectorId,
    required this.primaryColor,
    required this.iconId,
    this.balance,
  });

  factory ApiAccount.fromJson(Map<String, dynamic> json) {
    return ApiAccount(
      accountId: json['accountId'],
      bankName: json['bank_name'],
      accountType: json['account_type'],
      number: json['number'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      profile: json['profile'],
      iconId: json['connector_id'],
      connectorId: json['connector_id'],
      primaryColor: json['primary_color'],
      balance: json['balance'] != null ? double.parse(json['balance']) : null,
    );
  }
}
