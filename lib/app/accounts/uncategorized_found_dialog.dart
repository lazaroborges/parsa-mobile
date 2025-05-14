import 'package:flutter/material.dart';

class UncategorizedFoundDialog {
  /// Shows a dialog informing the user about uncategorized transactions.
  /// [transactionCount] is the number of uncategorized transactions found.
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
}

class _UncategorizedFoundDialogWidget extends StatelessWidget {
  final int transactionCount;
  const _UncategorizedFoundDialogWidget(
      {Key? key, required this.transactionCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Encontramos $transactionCount transações não categorizadas',
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Por favor, nos ajude a entendê-las.',
              style: textTheme.bodyLarge?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Depois'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Reclassificar agora'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
