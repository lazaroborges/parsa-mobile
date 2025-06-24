import 'package:flutter/material.dart';

class MultiValueProgressBar extends StatelessWidget {
  final double total;
  final List<ProgressBarValue> values;

  const MultiValueProgressBar({
    super.key,
    required this.total,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Container(
        height: 16,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background (green bar for income)
              Container(
                height: 16,
                color: Colors.green.withOpacity(0.9),
              ),
              // Foreground (red and blue bars)
              Row(
                children: values.map((value) {
                  final percentage = (total > 0) ? value.amount / total : 0.0;
                  if (percentage.isNaN ||
                      percentage.isInfinite ||
                      percentage <= 0) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    width: constraints.maxWidth * percentage,
                    height: 16,
                    child: Container(color: value.color),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProgressBarValue {
  final double amount;
  final Color color;

  ProgressBarValue({required this.amount, required this.color});
}
