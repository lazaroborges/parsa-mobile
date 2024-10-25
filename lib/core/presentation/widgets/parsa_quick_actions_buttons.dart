import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/details/account_details_actions.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/i18n/translations.g.dart';

class ParsaQuickActionsButtons extends StatelessWidget {
  const ParsaQuickActionsButtons({
    super.key,
    required this.account,
    required this.navigateBackOnDelete,
  });

  final Account account;
  final bool navigateBackOnDelete;

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
            () => AccountDetailsActions.disconnectAccount(context, account),
            isDisconnectAction: true,
          ),
          _buildActionButton(
            context,
            Icons.delete,
            t.account.delete_openfinance.title,
            () => AccountDetailsActions.deleteOpenFinanceAccount(
              context,
              account.id,
              navigateBackOnDelete,
            ),
            isDeleteAction: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isDeleteAction = false,
    bool isDisconnectAction = false,
  }) {
    final color = isDeleteAction
        ? Theme.of(context).colorScheme.error
        : isDisconnectAction
            ? Colors.yellow[700] // Stronger yellow color
            : Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color!.withOpacity(0.15),
          radius: 24,
          child: IconButton(
            onPressed: onPressed,
            color: color,
            icon: Transform.rotate(
              angle: isDisconnectAction ? -45 * (3.14159 / 180) : 0,
              child: Icon(
                icon,
                size: 32,
                weight: isDisconnectAction ? 900 : 500, // Bold for disconnect
              ),
            ),
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
