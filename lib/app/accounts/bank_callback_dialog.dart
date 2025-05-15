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
                      Icons.account_balance,
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
              'Conexão Concluída',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Body
            Text(
              'Sua conta bancária\nfoi conectada com sucesso!',
              style: TextStyle(
                fontSize: 16,
                color: appColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Deseja conectar outra conta?',
              style: TextStyle(
                fontSize: 16,
                color: appColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Connect another account button
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
                'Sim, conectar',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (showPdfOption) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Esperando carregamento da conta...'),
                    ),
                  );
                }
                Navigator.of(context).pop(false);
              },
              // Don't connect another account button
              child: Text(
                'Não conectar',
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
