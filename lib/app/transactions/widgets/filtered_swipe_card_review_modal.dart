import 'package:flutter/material.dart';
import 'package:parsa/core/utils/cousin_utils.dart';
import 'package:parsa/app/transactions/uncategorized/cousin_classification_overlay.dart';
import 'package:intl/intl.dart';

class FilteredSwipeCardReviewModal extends StatefulWidget {
  const FilteredSwipeCardReviewModal({super.key});

  @override
  State<FilteredSwipeCardReviewModal> createState() =>
      _FilteredSwipeCardReviewModalState();
}

class _FilteredSwipeCardReviewModalState
    extends State<FilteredSwipeCardReviewModal> {
  bool _loading = false;
  Map<String, CousinGroupResult?> _results = {};

  @override
  void initState() {
    super.initState();
    _fetchAllCounts();
  }

  Future<void> _fetchAllCounts() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(
        const Duration(days: 1, hours: -23, minutes: -59, seconds: -59));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
    final endOfThisMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final results = await Future.wait([
      getCousinGroupsForPeriod(startOfWeek, now), // this week
      getCousinGroupsForPeriod(startOfLastWeek, endOfLastWeek), // last week
      getCousinGroupsForPeriod(startOfMonth, endOfThisMonth), // this month
      getCousinGroupsForPeriod(startOfLastMonth, endOfLastMonth), // last month
    ]);
    setState(() {
      _results = {
        'thisWeek': results[0],
        'lastWeek': results[1],
        'thisMonth': results[2],
        'lastMonth': results[3],
      };
      _loading = false;
    });
  }

  void _openOverlay(CousinGroupResult result, String label) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => CousinClassificationOverlay(
        groups: result.groups,
        totalTransactions: result.totalTransactions,
        totalGroups: result.totalGroups,
        periodLabel: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                        _PeriodButton(
                          text: 'esta semana',
                          transactionCount:
                              _results['thisWeek']?.totalTransactions ?? 0,
                          businessCount: _results['thisWeek']?.totalGroups ?? 0,
                          onPressed: _results['thisWeek'] == null ||
                                  _results['thisWeek']!.groups.isEmpty
                              ? null
                              : () => _openOverlay(
                                  _results['thisWeek']!, 'Esta semana'),
                        ),
                        const SizedBox(height: 16),
                        _PeriodButton(
                          text: 'semana passada',
                          transactionCount:
                              _results['lastWeek']?.totalTransactions ?? 0,
                          businessCount: _results['lastWeek']?.totalGroups ?? 0,
                          onPressed: _results['lastWeek'] == null ||
                                  _results['lastWeek']!.groups.isEmpty
                              ? null
                              : () => _openOverlay(
                                  _results['lastWeek']!, 'Semana passada'),
                        ),
                        const SizedBox(height: 16),
                        _PeriodButton(
                          text: 'este mês',
                          transactionCount:
                              _results['thisMonth']?.totalTransactions ?? 0,
                          businessCount:
                              _results['thisMonth']?.totalGroups ?? 0,
                          onPressed: _results['thisMonth'] == null ||
                                  _results['thisMonth']!.groups.isEmpty
                              ? null
                              : () => _openOverlay(
                                  _results['thisMonth']!, 'Este mês'),
                        ),
                        const SizedBox(height: 16),
                        _PeriodButton(
                          text: 'mês passado',
                          transactionCount:
                              _results['lastMonth']?.totalTransactions ?? 0,
                          businessCount:
                              _results['lastMonth']?.totalGroups ?? 0,
                          onPressed: _results['lastMonth'] == null ||
                                  _results['lastMonth']!.groups.isEmpty
                              ? null
                              : () => _openOverlay(
                                  _results['lastMonth']!, 'Mês passado'),
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
  final VoidCallback? onPressed;

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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
