import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';

import 'package:parsa/app/accounts/pluggy_connector.dart'; 
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
      barrierDismissible: true,
      builder: (dialogContext) => _BankConnectionDialogWidget(
          showUncategorizedOption: showUncategorizedOption),
    );
  }

  /// Shows the dialog and handles the user's choice, including opening the account
  /// connection modal if the user chooses to connect another account.
  static Future<void> showAndHandle(BuildContext context) async {
    final result = await show(context);

    if (result == true && context.mounted) {
      // User wants to connect another account, go directly to PluggyConnectorPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PluggyConnectorPage(),
        ),
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, false); // Close the modal when tapping outside
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xB20F1728), // Semi-transparent background
        ),
        child: Stack(
          children: [
            // Center the modal content
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {}, // Prevents tap events from propagating to the background
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: appColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x07101828),
                        blurRadius: 8,
                        offset: Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Color(0x14101828),
                        blurRadius: 24,
                        offset: Offset(0, 20),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with 'X' button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48), // Placeholder for alignment
                          Text(
                            'Conexão em andamento',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: appColors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: appColors.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: 32,
                          color: appColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Body text
                      Text(
                        'Sua conta bancária está sendo sincronizada.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Você deseja conectar outra conta enquanto isso?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Options
                      Column(
                        children: [
                          _buildOptionTile(
                            context: context,
                            icon: Icons.add_circle_outline,
                            title: 'Sim, conectar',
                            description: 'Conectar outra conta bancária agora.',
                            onTap: () => Navigator.of(context).pop(true),
                          ),
                          const SizedBox(height: 16),
                          _buildOptionTile(
                            context: context,
                            icon: Icons.check_circle_outline,
                            title: 'Não conectar',
                            description: 'Finalizar processo de conexão.',
                            onTap: () async {
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              width: 1,
              color: Colors.blue.shade200,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Option Icon
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Icon(
                icon,
                color: appColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            // Option Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: appColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF344053),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
