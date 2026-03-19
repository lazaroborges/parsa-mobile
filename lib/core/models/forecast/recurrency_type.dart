import 'package:flutter/material.dart';

enum RecurrencyType {
  recurrent_fixed,
  recurrent_variable,
  irregular;

  String get displayName {
    switch (this) {
      case RecurrencyType.recurrent_fixed:
        return 'Fixo';
      case RecurrencyType.recurrent_variable:
        return 'Variavel';
      case RecurrencyType.irregular:
        return 'Irregular';
    }
  }

  Color get badgeColor {
    switch (this) {
      case RecurrencyType.recurrent_fixed:
        return Colors.blue;
      case RecurrencyType.recurrent_variable:
        return Colors.orange;
      case RecurrencyType.irregular:
        return Colors.grey;
    }
  }

  static RecurrencyType fromString(String value) {
    return RecurrencyType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrencyType.irregular,
    );
  }
}
