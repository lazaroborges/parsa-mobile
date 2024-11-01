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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: e.isEditable ? () {
                        if (e.value is GestureDetector) {
                          (e.value as GestureDetector).onTap?.call();
                        }
                      } : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      e.label,
                                      style: const TextStyle(fontWeight: FontWeight.w300),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  if (e.isEditable) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: e.isEditable ? () {
                        if (e.value is GestureDetector) {
                          (e.value as GestureDetector).onTap?.call();
                        }
                      } : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: e.value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
