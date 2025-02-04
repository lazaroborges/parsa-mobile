import 'package:flutter/material.dart';
import 'package:parsa/i18n/translations.g.dart';

class BottomSheetFooter extends StatelessWidget {
  const BottomSheetFooter({
    super.key,
    this.onSaved,
    this.submitText,
    this.submitIcon = Icons.save,
    this.showAddButton = false,
    this.onAddPressed,
  });

  /// The text inside the submiit button. Defaults to "save" in the current language
  final String? submitText;

  final IconData submitIcon;

  /// Function to trigger when the main button is pressed. The main button will be disabled if this function is null
  final void Function()? onSaved;

  final bool showAddButton;

  final void Function()? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final t = Translations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showAddButton)
            FilledButton.icon(
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey[200],
                disabledForegroundColor: Colors.grey,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar Tag'),
              onPressed: onAddPressed,
            )
          else
            const SizedBox(),
          FilledButton.icon(
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey[200],
              disabledForegroundColor: Colors.grey,
            ),
            icon: const Icon(Icons.check_box_rounded),
            label: Text(submitText ?? "Selecionar"),
            onPressed: onSaved != null
                ? () {
                    onSaved!();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
