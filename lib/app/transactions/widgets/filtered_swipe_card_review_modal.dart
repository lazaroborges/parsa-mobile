import 'package:flutter/material.dart';
import 'package:parsa/core/presentation/app_colors.dart';
import 'package:parsa/core/utils/cousin_utils.dart';
import 'package:parsa/app/transactions/cousin/cousin_classification_overlay.dart';
import 'package:intl/intl.dart';
import 'package:parsa/core/utils/shared_preferences_async.dart';
import 'package:parsa/core/models/date-utils/date_period_state.dart';

class FilteredSwipeCardReviewModal extends StatefulWidget {
  const FilteredSwipeCardReviewModal({super.key});

  @override
  State<FilteredSwipeCardReviewModal> createState() =>
      _FilteredSwipeCardReviewModalState();
}

class _FilteredSwipeCardReviewModalState
    extends State<FilteredSwipeCardReviewModal> {
  bool _loading = false;
  Map<String, List<CousinGroupSummary>> _results = {};
  int? _startOfWeek;
  int? _startOfMonth;

  // Store the calculated dates to reuse them
  late DateTime _thisWeekStart;
  late DateTime _lastWeekStart;
  late DateTime _lastWeekEnd;
  late DateTime _thisMonthStart;
  late DateTime _lastMonthStart;
  late DateTime _lastMonthEnd;
  late DateTime _allTimeStart;

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFetchCounts();
  }

  void _calculateDateRanges() {
    final now = DateTime.now();
    final int weekStart = _startOfWeek ?? DateTime.sunday; // fallback to Sunday

    // Find the start of this week
    final int daysSinceWeekStart = (now.weekday - weekStart + 7) % 7;
    _thisWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysSinceWeekStart));

    // Last week is 7 days before this week
    _lastWeekStart = _thisWeekStart.subtract(const Duration(days: 7));
    _lastWeekEnd = _thisWeekStart.subtract(
        const Duration(days: 1, hours: -23, minutes: -59, seconds: -59));

    final int monthStartDay = _startOfMonth ?? 1;

    // Start of this month - if today is before monthStartDay, this month is previous month
    _thisMonthStart = now.day < monthStartDay
        ? DateTime(now.year, now.month - 1, monthStartDay)
        : DateTime(now.year, now.month, monthStartDay);

    // Last month is always one month before this month
    _lastMonthStart = DateTime(
        _thisMonthStart.month == 1
            ? _thisMonthStart.year - 1
            : _thisMonthStart.year,
        _thisMonthStart.month == 1 ? 12 : _thisMonthStart.month - 1,
        monthStartDay);

    // End of last month: day before thisMonthStart, at 23:59:59
    _lastMonthEnd = _thisMonthStart.subtract(
        const Duration(days: 1, hours: -23, minutes: -59, seconds: -59));

    // All time start (set to a reasonable past date)
    _allTimeStart = DateTime(2020, 1, 1);
  }

  Future<void> _loadPreferencesAndFetchCounts() async {
    final startOfWeek = await SharedPreferencesAsync.instance.getStartOfWeek();
    final startOfMonth =
        await SharedPreferencesAsync.instance.getStartOfMonth();
    setState(() {
      _startOfWeek = startOfWeek;
      _startOfMonth = startOfMonth;
    });
    await _fetchAllCounts();
  }

  Future<void> _fetchAllCounts() async {
    setState(() => _loading = true);

    _calculateDateRanges();
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final results = await Future.wait([
      getCousinGroupSummariesForPeriod(_thisWeekStart, endOfToday), // this week
      getCousinGroupSummariesForPeriod(
          _lastWeekStart, _lastWeekEnd), // last week
      getCousinGroupSummariesForPeriod(
          _thisMonthStart, endOfToday), // this month
      getCousinGroupSummariesForPeriod(
          _lastMonthStart, _lastMonthEnd), // last month
      getCousinGroupSummariesForPeriod(_allTimeStart, now), // all time
    ]);

    // Sort each list by total amount before storing
    final sortedResults = results.map((groups) {
      return List<CousinGroupSummary>.from(groups)
        ..sort((a, b) => b.totalAmount.abs().compareTo(a.totalAmount.abs()));
    }).toList();

    setState(() {
      _results = {
        'thisWeek': sortedResults[0],
        'lastWeek': sortedResults[1],
        'thisMonth': sortedResults[2],
        'lastMonth': sortedResults[3],
        'allTime': sortedResults[4],
      };
      _loading = false;
    });
  }

  void _openOverlay(List<CousinGroupSummary> groups, String label) {
    Navigator.of(context).pop();

    final totalTransactions =
        groups.fold(0, (sum, item) => sum + item.transactionCount);
    final totalGroups = groups.length;

    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    DateTime periodStart;
    DateTime periodEnd;

    switch (label) {
      case 'Esta semana':
        periodStart = _thisWeekStart;
        periodEnd = endOfToday;
        break;
      case 'Semana passada':
        periodStart = _lastWeekStart;
        periodEnd = _lastWeekEnd;
        break;
      case 'Este mês':
        periodStart = _thisMonthStart;
        periodEnd = endOfToday;
        break;
      case 'Mês passado':
        periodStart = _lastMonthStart;
        periodEnd = _lastMonthEnd;
        break;
      case 'Todo o período':
        periodStart = _allTimeStart;
        periodEnd = endOfToday;
        break;
      default:
        periodStart = now;
        periodEnd = endOfToday;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => CousinClassificationOverlay(
        groups: groups,
        totalTransactions: totalTransactions,
        totalGroups: totalGroups,
        periodLabel: label,
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the modal when tapping outside
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
                onTap:
                    () {}, // Prevents tap events from propagating to the background
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxHeight: 600,
                  ),
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 12,
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
                  child: _loading
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header with 'X' button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                      width: 48), // Placeholder for alignment
                                  Text(
                                    'Rever Transações',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: appColors.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              const SizedBox(height: 12),

                              // Body text
                              Text(
                                'Escolha o período para revisar suas transações',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: appColors.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),

                              // Period options
                              Column(
                                children: [
                                  _buildPeriodTile(
                                    context: context,
                                    icon: Icons.today,
                                    title: 'Esta semana',
                                    groups: _results['thisWeek'] ?? [],
                                    onTap: (_results['thisWeek'] ?? []).isEmpty
                                        ? null
                                        : () => _openOverlay(
                                            _results['thisWeek']!,
                                            'Esta semana'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPeriodTile(
                                    context: context,
                                    icon: Icons.history,
                                    title: 'Semana passada',
                                    groups: _results['lastWeek'] ?? [],
                                    onTap: (_results['lastWeek'] ?? []).isEmpty
                                        ? null
                                        : () => _openOverlay(
                                            _results['lastWeek']!,
                                            'Semana passada'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPeriodTile(
                                    context: context,
                                    icon: Icons.calendar_month,
                                    title: 'Este mês',
                                    groups: _results['thisMonth'] ?? [],
                                    onTap: (_results['thisMonth'] ?? []).isEmpty
                                        ? null
                                        : () => _openOverlay(
                                            _results['thisMonth']!, 'Este mês'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPeriodTile(
                                    context: context,
                                    icon: Icons.calendar_today,
                                    title: 'Mês passado',
                                    groups: _results['lastMonth'] ?? [],
                                    onTap: (_results['lastMonth'] ?? []).isEmpty
                                        ? null
                                        : () => _openOverlay(
                                            _results['lastMonth']!,
                                            'Mês passado'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPeriodTile(
                                    context: context,
                                    icon: Icons.all_inclusive,
                                    title: 'Todo o período',
                                    groups: _results['allTime'] ?? [],
                                    onTap: (_results['allTime'] ?? []).isEmpty
                                        ? null
                                        : () => _openOverlay(
                                            _results['allTime']!,
                                            'Todo o período'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<CousinGroupSummary> groups,
    required VoidCallback? onTap,
  }) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);

    final transactionCount =
        groups.fold(0, (sum, item) => sum + item.transactionCount);
    final businessCount = groups.map((s) => s.cousin).toSet().length;

    final isEnabled = onTap != null && transactionCount > 0;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              width: 1,
              color: isEnabled ? Colors.blue.shade200 : Colors.grey.shade300,
            ),
          ),
          shadows: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
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
                color: isEnabled ? appColors.primary : Colors.grey.shade400,
                size: 16,
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
                      color: isEnabled
                          ? appColors.onSurface
                          : Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transactionCount > 0
                        ? '$transactionCount transações de $businessCount pessoas e negócios'
                        : 'Nenhuma transação encontrada',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isEnabled
                          ? const Color(0xFF344053)
                          : Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (isEnabled)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: appColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
