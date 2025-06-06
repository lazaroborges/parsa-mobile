import 'package:flutter/material.dart';

class FilteredSwipeCardReviewModal extends StatelessWidget {
  const FilteredSwipeCardReviewModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Classificar Transações',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Main content area with buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Esta semana button
                  _PeriodButton(
                    text: 'esta semana',
                    transactionCount: 45,
                    businessCount: 12,
                    onPressed: () {
                      // TODO: Navigate to uncategorized overlay with this week filter
                      print('Esta semana pressed');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Semana passada button
                  _PeriodButton(
                    text: 'semana passada...',
                    transactionCount: 38,
                    businessCount: 15,
                    onPressed: () {
                      // TODO: Navigate to uncategorized overlay with last week filter
                      print('Semana passada pressed');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Este mês button
                  _PeriodButton(
                    text: 'este mês',
                    transactionCount: 127,
                    businessCount: 23,
                    onPressed: () {
                      // TODO: Navigate to uncategorized overlay with this month filter
                      print('Este mês pressed');
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Mês passado button
                  _PeriodButton(
                    text: 'mês passado',
                    transactionCount: 89,
                    businessCount: 18,
                    onPressed: () {
                      // TODO: Navigate to uncategorized overlay with last month filter
                      print('Mês passado pressed');
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer with cancel button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String text;
  final int transactionCount;
  final int businessCount;
  final VoidCallback onPressed;

  const _PeriodButton({
    required this.text,
    required this.transactionCount,
    required this.businessCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$transactionCount transações de $businessCount pessoas e negócios',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 