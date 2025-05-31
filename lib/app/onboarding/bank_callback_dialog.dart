import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/app/accounts/account_connection_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';

/// A modal dialog that asks the user if they want to connect another bank account
/// after returning from a bank connection flow.
class BankConnectionDialog {
  /// Shows the dialog asking if the user wants to connect another bank account.
  ///
  /// Returns true if the user wants to connect another account, false otherwise.
  static Future<bool?> show(BuildContext context,
      {bool showUncategorizedOption = true}) async {
    // Show the dialog with a safety check
    if (!context.mounted) {
      if (kDebugMode) {
        print('🏦 BankConnectionDialog: Context not mounted, skipping dialog');
      }
      return null;
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _BankConnectionDialogWidget(
          showUncategorizedOption: showUncategorizedOption),
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

class _BankConnectionDialogWidget extends StatelessWidget {
  final bool showUncategorizedOption;

  const _BankConnectionDialogWidget({
    Key? key,
    this.showUncategorizedOption = true,
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
                // Positioned(
                //   right: 0,
                //   top: 0,
                //   child: GestureDetector(
                //     onTap: () => Navigator.of(context).pop(false),
                //     child: Icon(
                //       Icons.close,
                //       size: 24,
                //       color: appColors.primary,
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Conexão em andamento',
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
              'Sua conta bancária está\n em processo de conexão!',
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
              ),
              child: const Text(
                'Sim, conectar',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                if (showUncategorizedOption) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Esperando carregamento da conta...'),
                    ),
                  );
                }
                // Call the API to set has_finished_openfinance_flow = true
                final success = await PostUserSettings.finishOpenFinanceFlow();
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao finalizar fluxo Open Finance.'),
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
