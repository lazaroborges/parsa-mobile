import 'package:flutter/material.dart';
import 'package:parsa/i18n/translations.g.dart';
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
    final t = Translations.of(context);
    return AlertDialog(
      title: Text('Titulo'),
      content: Text('Conteudo'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fechar'),
        ),
      ],
    );
  }
}
