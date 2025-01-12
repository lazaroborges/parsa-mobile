import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:parsa/app/transactions/label_value_info_table.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class LabelValueInfoListItem extends LabelValueInfoItem {
  final Widget? trailing;

  LabelValueInfoListItem({
    required Widget value,
    required String label,
    this.trailing,
  }) : super(
          value: (value is Text) 
              ? Text.rich(
                  TextSpan(text: value.data),
                  textAlign: value.textAlign,
                  softWrap: value.softWrap,
                  overflow: value.overflow,
                )
              : value,
          label: label,
        );
}

class LabelValueInfoList extends StatelessWidget {
  const LabelValueInfoList({super.key, required this.items});

  final List<LabelValueInfoListItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.mapIndexed((index, element) {
        return ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(element.label),
          subtitle: element.value,
          trailing: element.trailing,
          tileColor: index % 2 != 0
              ? AppColors.of(context).surface
              : Theme.of(context).colorScheme.surfaceContainerLowest,
        );
      }).toList(),
    );
  }
}
