import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpModalService {
  static const _lastShownDateKey = 'help_modal_last_shown_date';

  static Future<bool> shouldShowHelpModal() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownDateString = prefs.getString(_lastShownDateKey);

    if (lastShownDateString == null) {
      return true; // Never shown before
    }

    final lastShownDate = DateTime.tryParse(lastShownDateString);
    if (lastShownDate == null) {
      return true; // Corrupted data
    }

    final now = DateTime.now();
    // Compare just the date part (year, month, day)
    final isSameDay = now.year == lastShownDate.year &&
        now.month == lastShownDate.month &&
        now.day == lastShownDate.day;

    return !isSameDay;
  }

  static Future<void> markHelpModalAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShownDateKey, DateTime.now().toIso8601String());
  }

  static Future<void> showHelpModal(BuildContext context) async {
    // After showing, mark it as shown for the day.
    await markHelpModalAsShown();
    await showDialog(
      context: context,
      builder: (context) => const HelpModal(),
    );
  }

  static Future<void> forceShowHelpModal(BuildContext context) async {
    // This is for FCM. It should show the modal regardless of the date check.
    // And also mark it as shown, so it doesn't show again on the same day through normal flow.
    await markHelpModalAsShown();
    await showDialog(
      context: context,
      builder: (context) => const HelpModal(),
    );
  }
}

class HelpModal extends StatelessWidget {
  const HelpModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final storeLink =
        "https://play.google.com/store/apps/details?id=com.parsa.app";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: appColors.modalBackground,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 56,
                    color: appColors.brandLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ajude o Parsa',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ajude o Parsa a crescer compartilhando o link do aplicativo na loja',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: appColors.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: appColors.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColors.primaryContainer,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            storeLink,
                            style: textTheme.bodyMedium?.copyWith(
                              color: appColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          color: appColors.onPrimaryContainer,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: storeLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Link copiado para a área de transferência'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
                  backgroundColor: appColors.light,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
