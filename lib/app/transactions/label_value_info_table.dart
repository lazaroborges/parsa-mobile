import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';

class LabelValueInfoItem {
  final Widget value;
  final String label;
  final bool isEditable;

  const LabelValueInfoItem({
    required this.value,
    required this.label,
    this.isEditable = false,
  });
}

class LabelValueInfoTable extends StatelessWidget {
  const LabelValueInfoTable({super.key, required this.items});

  final List<LabelValueInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(borderRadius: BorderRadius.circular(0)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(7),
      },
      children: items
          .mapIndexed(
            (i, e) => TableRow(
              decoration: BoxDecoration(
                color: i % 2 != 0
                    ? AppColors.of(context).surface
                    : Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.label,
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        if (e.isEditable) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                        ],
                      ],
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: e.value,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
