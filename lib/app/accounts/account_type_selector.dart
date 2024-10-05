import 'package:flutter/material.dart';
import 'package:parsa/core/models/account/account.dart';

import '../../core/presentation/app_colors.dart';

class AccountTypeSelector extends StatefulWidget {
  const AccountTypeSelector({
    super.key,
    required this.onSelected,
    this.selectedType = AccountType.normal,
  });

  final AccountType selectedType;
  final Function(AccountType) onSelected;

  @override
  State<AccountTypeSelector> createState() => _AccountTypeSelectorState();
}

class _AccountTypeSelectorState extends State<AccountTypeSelector> {
  late AccountType selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Each chip gets its own row in a vertical layout
      children: List.generate(
        AccountType.values.length,
        (index) {
          final AccountType item = AccountType.values[index];

          return Padding(
            padding:
                const EdgeInsets.only(bottom: 8.0), // Add spacing between rows
            child: MonekinFilterChip(
              accountType: item,
              onPressed: () {
                setState(() {
                  selectedItem = item;
                  widget.onSelected(item);
                });
              },
              isSelected: item == selectedItem,
            ),
          );
        },
      ),
    );
  }
}

class MonekinFilterChip extends StatelessWidget {
  const MonekinFilterChip({
    super.key,
    required this.accountType,
    required this.onPressed,
    required this.isSelected,
  });

  final VoidCallback onPressed;
  final bool isSelected;
  final AccountType accountType;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          width: 1.25,
          color:
              isSelected ? AppColors.of(context).primary : Colors.transparent,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed.call,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            // Icon and text horizontally aligned within the row
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                accountType.icon,
                size: 28,
                color: isSelected
                    ? AppColors.of(context).primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12), // Space between icon and text
              Expanded(
                // Ensure the text column takes up remaining space
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the start
                  children: [
                    Text(
                      accountType.title(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? AppColors.of(context).primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountType.description(context),
                      softWrap: true, // Allow text to wrap to new lines
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
