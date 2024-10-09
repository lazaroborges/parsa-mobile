import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/widgets/confirm_dialog.dart';
import 'package:parsa/i18n/translations.g.dart';

class ParsaQuickActionsButtons extends StatelessWidget {
  const ParsaQuickActionsButtons({
    super.key,
    required this.onDisconnect,
    required this.onDelete,
  });

  final VoidCallback onDisconnect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            Icons.link_off,
            t.account.disconnect.title,
            () => _showWarningDialog(
              context,
              t.account.disconnect.warning_header,
              t.account.disconnect.warning_text,
              onDisconnect,
            ),
          ),
          _buildActionButton(
            context,
            Icons.delete,
            t.account.delete_openfinance.title,
            () => _showWarningDialog(
              context,
              t.account.delete_openfinance.warning_header,
              t.account.delete_openfinance.warning_text,
              onDelete,
            ),
            isDeleteAction: true,
          ),
        ],
      ),
    );
  }

  Future<void> _showWarningDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) async {
    final t = Translations.of(context);
    final result = await confirmDialog(
      context,
      dialogTitle: title,
      contentParagraphs: [Text(content)],
      confirmationText: t.general.continue_text,
      showCancelButton: true,
      icon: Icons.warning_rounded,
    );

    if (result == true) {
      onConfirm();
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isDeleteAction = false,
  }) {
    final color = isDeleteAction
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 24,
          child: IconButton(
            onPressed: onPressed,
            color: color,
            icon: Icon(icon, size: 32),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
}
