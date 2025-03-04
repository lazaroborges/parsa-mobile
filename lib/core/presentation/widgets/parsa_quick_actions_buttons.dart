import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/details/account_details_actions.dart';
import 'package:parsa/app/accounts/pluggy_connector.dart';
import 'package:parsa/core/api/fetch_user_accounts.dart';
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (account.hasMFA)
            Expanded(
              child: _buildActionButton(
                context,
                Icons.refresh,
                _buildMultilineText("Atualizar"),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PluggyConnectorPage(
                        accountId: account.id,
                        isUpdate: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _buildActionButton(
              context,
              account.hiddenByUser ? Icons.visibility : Icons.visibility_off,
              _buildMultilineText(
                account.hiddenByUser ? "Visualizar" : "Ocultar"
              ),
              () => AccountDetailsActions.toggleAccountVisibility(
                context,
                account,
                false,
              ),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              context,
              account.removed ? Icons.restore : Icons.remove_circle,
              _buildMultilineText(
                account.removed ? t.account.restore.title : t.account.remove.title
              ),
              () => account.removed
                  ? AccountDetailsActions.restoreAccount(
                      context,
                      account.id,
                      navigateBackOnDelete,
                    )
                  : AccountDetailsActions.removeAccount(
                      context,
                      account.id,
                      navigateBackOnDelete,
                    ),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              context,
              Icons.link_off,
              _buildMultilineText(t.account.disconnect.title),
              () => AccountDetailsActions.disconnectAccount(context, account),
              isDisconnectAction: true,
            ),
          ),
          Expanded(
            child: _buildActionButton(
              context,
              Icons.delete,
              _buildMultilineText(t.account.delete_openfinance.title),
              () async {
                await AccountDetailsActions.deleteOpenFinanceAccount(
                  context,
                  account.id,
                  navigateBackOnDelete,
                );
                // Refresh accounts after deletion
                await fetchUserAccounts();
              },
              isDeleteAction: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    Widget label,
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
        label,
      ],
    );
  }

  Widget _buildMultilineText(String text) {
    return SizedBox(
      height: 40, // Fixed height for text container
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: text.split(' ').map((word) => Text(
          word,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        )).toList(),
      ),
    );
  }
}
