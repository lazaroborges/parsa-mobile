import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/app/accounts/account_connection_modal.dart';
import 'package:flutter/foundation.dart';

/// A modal dialog that asks the user if they want to connect another bank account
/// after returning from a bank connection flow.
class BankCallbackDialog {
  /// Shows the dialog asking if the user wants to connect another bank account.
  ///
  /// Returns true if the user wants to connect another account, false otherwise.
  static Future<bool?> show(BuildContext context,
      {bool showPdfOption = true}) async {
    // Show the dialog with a safety check
    if (!context.mounted) {
      if (kDebugMode) {
        print('🏦 BankCallbackDialog: Context not mounted, skipping dialog');
      }
      return null;
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          _BankCallbackDialogWidget(showPdfOption: showPdfOption),
    );
  }

  /// Shows the dialog and handles the user's choice, including opening the account
  /// connection modal if the user chooses to connect another account.
  static Future<void> showAndHandle(BuildContext context) async {
    final result = await show(context);

    if (result == true && context.mounted) {
      // User wants to connect another account, show the modal with full screen
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AccountConnectionModal(),
      );
    }
    // If result is false, the PDF message was already shown in the dialog
  }
}

class _BankCallbackDialogWidget extends StatelessWidget {
  final bool showPdfOption;

  const _BankCallbackDialogWidget({
    Key? key,
    this.showPdfOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: appColors.modalBackground,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance,
                  size: 56,
                  color: appColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Conexão Concluída',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: appColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua conta bancária foi conectada com sucesso. Deseja conectar outra conta bancária?',
                  style: textTheme.bodyLarge?.copyWith(
                    color: appColors.onSurface,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (showPdfOption) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Esperando carregamento da conta...')),
                            );
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: appColors.primary),
                          ),
                          child: Text(
                            'Não',
                            style: textTheme.labelLarge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: appColors.primary,
                        ),
                        child: Text(
                          'Sim, conectar',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: appColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: appColors.onSurface),
              style: IconButton.styleFrom(
                backgroundColor: appColors.surface,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
