import 'package:flutter/material.dart';
import 'package:parsa/core/models/forecast/recurrency_type.dart';

class RecurrencyTypeBadge extends StatelessWidget {
  const RecurrencyTypeBadge({
    super.key,
    required this.recurrencyType,
    this.small = false,
  });

  final RecurrencyType recurrencyType;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: recurrencyType.badgeColor.withOpacity(0.15),
        border: Border.all(
          color: recurrencyType.badgeColor.withOpacity(0.4),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        recurrencyType.displayName,
        style: TextStyle(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: recurrencyType.badgeColor,
        ),
      ),
    );
  }
}
