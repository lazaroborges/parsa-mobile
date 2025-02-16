import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:parsa/app/accounts/account_form.dart';
import 'package:parsa/app/accounts/details/account_details.dart';
import 'package:parsa/app/transactions/form/transaction_form.page.dart';
import 'package:parsa/core/database/services/account/account_service.dart';
import 'package:parsa/core/models/account/account.dart';
import 'package:parsa/core/presentation/widgets/confirm_dialog.dart';
import 'package:parsa/core/routes/route_utils.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/core/utils/list_tile_action_item.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/core/api/post_methods/post_user_account.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction/transaction_type.enum.dart';

abstract class AccountDetailsActions {
  static List<ListTileActionItem> getAccountDetailsActions(
    BuildContext context, {
    required Account account,
    bool navigateBackOnDelete = false,
  }) {
    final t = Translations.of(context);

    return [
      ListTileActionItem(
        label: t.general.edit,
        icon: Icons.edit,
        onClick: () =>
            RouteUtils.pushRoute(context, AccountFormPage(account: account)),
      ),
      ListTileActionItem(
        label: account.hiddenByUser 
            ? "Visualizar"
            : "Ocultar",
        icon: account.hiddenByUser 
            ? Icons.visibility
            : Icons.visibility_off,
        onClick: () => toggleAccountVisibility(
          context,
          account,
          false,
        ),
      ),
      ListTileActionItem(
          label: t.transfer.create,
          icon: TransactionType.T.icon,
          onClick: account.isClosed
              ? null
              : () async {
                  showAccountsWarn() async =>
                      await confirmDialog(context,
                          dialogTitle:
                              t.transfer.need_two_accounts_warning_header,
                          contentParagraphs: [
                            Text(t.transfer.need_two_accounts_warning_message)
                          ]);

                  navigateToTransferForm() => RouteUtils.pushRoute(
                        context,
                        TransactionFormPage(
                          fromAccount: account,
                          mode: TransactionType.T,
                        ),
                      );

                  final numberOfAccounts = (await AccountService.instance
                          .getAccounts(
                            predicate: (acc, curr) => acc.closingDate.isNull(),
                          )
                          .first)
                      .length;

                  if (numberOfAccounts <= 1) {
                    await showAccountsWarn();
                  } else {
                    await navigateToTransferForm();
                  }
                }),
      ListTileActionItem(
          label: account.isClosed
              ? t.account.reopen_short
              : t.account.close.title_short,
          icon: account.isClosed
              ? Icons.unarchive_rounded
              : Icons.archive_rounded,
          role: ListTileActionRole.warn,
          onClick: () async {
            if (account.isClosed) {
              showReopenAccountDialog(context, account);
              return;
            }

            final currentBalance = await AccountService.instance
                .getAccountMoney(account: account)
                .first;

            await showCloseAccountDialog(context,
                account: account, currentBalance: currentBalance);
          }),
      ListTileActionItem(
          label: t.general.delete,
          icon: Icons.delete,
          role: ListTileActionRole.delete,
          onClick: () {
            deleteAccountWithAlertAndSnackBar(
              context,
              accountId: account.id,
              navigateBack: navigateBackOnDelete,
            );
          }),
    ];
  }

  static showReopenAccountDialog(BuildContext context, Account account) {
    confirmDialog(
      context,
      showCancelButton: true,
      dialogTitle: t.account.reopen,
      contentParagraphs: [
        Text(t.account.reopen_descr),
      ],
      confirmationText: t.general.confirm,
    ).then((isConfirmed) {
      AccountService.instance
          .updateAccount(
        account.copyWith(
          closingDate: const drift.Value(null),
        ),
      )
          .then((value) {
        if (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.account.close.unarchive_succes)),
          );
        }
      }).catchError((err) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$err')));
      });
    });
  }

  static Future<bool?> showCloseAccountDialog(BuildContext context,
      {required Account account, required double currentBalance}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          ArchiveWarnDialog(currentBalance: currentBalance, account: account),
    );
  }

  static Future<void> deleteAccountWithAlertAndSnackBar(
    BuildContext context, {
    required String accountId,
    required bool navigateBack,
  }) async {
    final scaffold = ScaffoldMessenger.of(context);
    final t = Translations.of(context);

    final isConfirmed = await confirmDialog(
      context,
      dialogTitle: t.account.delete.warning_header,
      contentParagraphs: [Text(t.account.delete.warning_text)],
      confirmationText: t.general.continue_text,
      showCancelButton: true,
      icon: Icons.delete,
    );

    if (isConfirmed != true) return;

    try {
      await AccountService.instance.deleteAccount(accountId);

      if (navigateBack) {
        Navigator.of(context).pop();
      }

      scaffold.showSnackBar(SnackBar(content: Text(t.account.delete.success)));
    } catch (err) {
      scaffold.showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  static Future<void> disconnectAccount(BuildContext context, Account account) async {
    final scaffold = ScaffoldMessenger.of(context);
    final t = Translations.of(context);

    final isConfirmed = await confirmDialog(
      context,
      dialogTitle: t.account.disconnect.warning_header,
      contentParagraphs: [Text(t.account.disconnect.warning_text)],
      confirmationText: t.general.continue_text,
      showCancelButton: true,
      icon: Icons.link_off,
    );

    if (isConfirmed != true) return;

    try {
      final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
      final credentials = auth0Provider.credentials;

      if (credentials == null) {
        throw Exception('User is not logged in');
      }

      final accessToken = credentials.accessToken;

      final success = await PostUserAccountService.disconnectAccount(
          account.id, accessToken);

      if (success) {
        // Close the account in the local database
        await AccountService.instance.updateAccount(
          account.copyWith(
            closingDate: drift.Value(DateTime.now()),
          ),
        );
        scaffold.showSnackBar(
            SnackBar(content: Text(t.account.disconnect.success)));
      } else {
        throw Exception('Failed to disconnect account');
      }
    } catch (err) {
      scaffold.showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  static Future<void> deleteOpenFinanceAccount(
    BuildContext context,
    String accountId,
    bool navigateBack,
  ) async {
    final t = Translations.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    final isConfirmed = await confirmDialog(
      context,
      dialogTitle: t.account.delete_openfinance.warning_header,
      contentParagraphs: [Text(t.account.delete_openfinance.warning_text)],
      confirmationText: t.general.continue_text,
      showCancelButton: true,
      icon: Icons.delete,
    );

    if (isConfirmed != true) return;

    // Show loading snackbar
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text("Seu consentimento Open Finance para o Parsa está sendo removido junto com os dados desta conta bancária. Este processo pode levar até 1 minuto para ser concluído."),
          ],
        ),
        duration: const Duration(seconds: 30), // Long duration as it might take time
      ),
    );

    try {
      final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
      final credentials = await auth0Provider.credentials;

      if (credentials == null) {
        throw Exception('User is not logged in');
      }

      final accessToken = credentials.accessToken;
      final success = await PostUserAccountService.deleteOpenFinanceAccount(
          accountId, accessToken);

      if (success) {
        // Hide the loading snackbar
        scaffold.hideCurrentSnackBar();

        // Delete the account from the local database
        await AccountService.instance.deleteAccountFromLocalDB(accountId);

        if (navigateBack) {
          Navigator.pop(context);
        }

        scaffold.showSnackBar(
            SnackBar(content: Text(t.account.delete_openfinance.success)));
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (err) {
      // Hide the loading snackbar
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  static Future<void> removeAccount(
    BuildContext context,
    String accountId,
    bool navigateBack,
  ) async {
    final success = await AccountService.instance.removeAccount(accountId);
    if (success && navigateBack) {
      Navigator.of(context).pop();
    }
  }

  static Future<void> restoreAccount(
    BuildContext context,
    String accountId,
    bool navigateBack,
  ) async {
    final t = Translations.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    // Show immediate feedback
    scaffold.showSnackBar(
      SnackBar(content: Text(t.account.restore.in_progress)),
    );

    // Navigate back immediately if needed
    if (navigateBack) {
      Navigator.of(context).pop();
    }

    // Fire and forget the restore operation
    unawaited(AccountService.instance.restoreAccount(accountId).then((success) {
      if (success) {
        scaffold.showSnackBar(
          SnackBar(content: Text(t.account.restore.success)),
        );
      }
    }));
  }

  static Future<void> toggleAccountVisibility(
    BuildContext context,
    Account account,
    bool navigateBack,
  ) async {
    try {
      await AccountService.instance.updateAccount(
        account.copyWith(
          hiddenByUser: !account.hiddenByUser,
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !account.hiddenByUser 
                ? "Sua conta não vai mais aparecer no Dashboard. Você pode reverter essa ação clicando novamente no mesmo botão. "
                : "Sua conta voltará a ser visualizada no Dashboard novamente."
            ),
          ),
        );
        
        if (navigateBack) {
          Navigator.pop(context);
        }
      }
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$err')),
        );
      }
    }
  }
}
