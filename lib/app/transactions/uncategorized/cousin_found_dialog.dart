import 'package:flutter/material.dart';
import 'package:parsa/app/transactions/uncategorized/cousin_classification_overlay.dart';
import 'package:parsa/core/api/post_methods/post_user_settings.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:parsa/core/utils/cousin_utils.dart';

class CousinFoundDialog {
  /// Shows a dialog informing the user about uncategorized transactions.
  /// [transactionCount] is the total number of uncategorized transactions.
  /// Returns true if the user wants to reclassify now, false if they choose later.
  static Future<bool?> show(BuildContext context,
      {required int cousinCount}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CousinFoundDialogWidget(cousinCount: cousinCount),
    );
  }

  /// Shows the dialog and handles the user's choice, including navigation
  /// to the reclassification overlay if the user chooses to reclassify now.
  static Future<void> showAndHandle(BuildContext context,
      {required int cousinCount}) async {
    final result = await show(context, cousinCount: cousinCount);

    if (result == true && context.mounted) {
      // User wants to reclassify now, show the overlay
      // Use entire year instead of just current month
      final now = DateTime.now();
      final startOfTime = DateTime(1900, 1, 1); // Far enough back to catch all transactions
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      print('-------- s3123124124 -------- Fetching cousin groups for period: $startOfTime to $endOfToday');
      final cousinResult =
          await getCousinGroupsForPeriod(startOfTime, endOfToday);
          
      // Sort groups by total value in descending order
      final sortedGroups = List<TransactionGroupByType>.from(cousinResult.groups)
        ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
      
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (context) =>
            CousinClassificationOverlay(groups: sortedGroups),
      );
    }
  }
}

class _CousinFoundDialogWidget extends StatelessWidget {
  final int cousinCount;

  const _CousinFoundDialogWidget({
    Key? key,
    required this.cousinCount,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with 'X' button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48), // Placeholder for alignment
                          Text(
                            'Revisar Transações',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: appColors.onSurface,
                              fontSize: 20,
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
                      
                      // Body text
                      Text(
                        'Terminamos de sincronizar suas contas e encontramos transações de $cousinCount pessoas e negócios diferentes.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vamos revisar as transações?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 24),
                      
                      // Options
                      Column(
                        children: [
                          _buildOptionTile(
                            context: context,
                            icon: Icons.check_circle,
                            title: 'Sim!',
                            description: 'Revisar minhas transações agora.',
                            onTap: () async {
                              await PostUserSettings.triggerSwipeCardsFlow();
                              UserDataProvider.instance.updateUserData({
                                'trigger_swipe_cards_flow': false,
                              });
                              Navigator.of(context).pop(true);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildOptionTile(
                            context: context,
                            icon: Icons.schedule,
                            title: 'Mais tarde',
                            description: 'Revisar as transações em outro momento.',
                            onTap: () => Navigator.of(context).pop(false),
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