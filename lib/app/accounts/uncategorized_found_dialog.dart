import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/uncategorized_classification_overlay.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/utils/uncategorized_utils.dart';

class UncategorizedFoundDialog {
  /// Shows a dialog informing the user about uncategorized transactions.
  /// [transactionCount] is the total number of uncategorized transactions.
  /// Returns true if the user wants to reclassify now, false if they choose later.
  static Future<bool?> show(BuildContext context,
      {required int transactionCount}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          _UncategorizedFoundDialogWidget(transactionCount: transactionCount),
    );
  }

  /// Shows the dialog and handles the user's choice, including navigation
  /// to the reclassification overlay if the user chooses to reclassify now.
  static Future<void> showAndHandle(BuildContext context,
      {List<Map<String, dynamic>>? top10Groups}) async {
    int count;
    if (top10Groups != null) {
      count = top10Groups.fold<int>(
          0, (sum, g) => sum + (g['totalTransactions'] as int));
    } else {
      count = await countTopUncategorizedTransactions();
    }
    final result = await show(context, transactionCount: count);

    if (result == true && context.mounted) {
      // User wants to reclassify now, show the overlay
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (context) => const UncategorizedClassificationOverlay(),
      );
    }
  }
}

class _UncategorizedFoundDialogWidget extends StatelessWidget {
  final int transactionCount;

  const _UncategorizedFoundDialogWidget({
    Key? key,
    required this.transactionCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: const Color(0xFFF8F9FE),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.archive,
                      size: 40,
                      color: appColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: appColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Reclassificar transações',
              style: TextStyle(
                fontSize: 24,
                color: appColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Body
            Text(
              'Encontramos $transactionCount transações não classificadas.',
              style: TextStyle(
                fontSize: 16,
                color: appColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Deseja reclassificar?',
              style: TextStyle(
                fontSize: 16,
                color: appColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Reclassify button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                foregroundColor: appColors.onPrimary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Sim, reclassificar',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            // Later button
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Mais tarde',
                style: TextStyle(
                  fontSize: 16,
                  color: appColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
