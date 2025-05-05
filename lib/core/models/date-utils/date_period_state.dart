import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parsa/core/models/date-utils/date_period.dart';
import 'package:parsa/core/models/date-utils/period_type.dart';
import 'package:parsa/core/models/date-utils/periodicity.dart';

part 'date_period_state.g.dart';

/// Calculates the actual start date for a period.
/// If useWorkingDays is true, it finds the Nth (startDay) working day of the month.
/// If useWorkingDays is false, it uses the literal startDay, clamping to the end of the month if invalid.
/// Returns a DateTime with time set to 00:00:00 (DateOnly).
DateTime _calculatePeriodStart(int year, int month, int startDay) {
  if (startDay <= 0) {
    startDay = 1;
  }
  try {
    return DateUtils.dateOnly(DateTime(year, month, startDay));
  } catch (e) {
    return DateUtils.dateOnly(DateTime(year, month + 1, 0));
  }
}

DateTime _setEndOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

@CopyWith()
class DatePeriodState {
  final DatePeriod datePeriod;
  final int periodModifier;
  final int startOfMonthDay;
  final int startOfWeek;

  const DatePeriodState({
    this.datePeriod = const DatePeriod(periodType: PeriodType.cycle),
    this.periodModifier = 0,
    this.startOfMonthDay = 1,
    this.startOfWeek = DateTime.sunday,
  });

  DateTime? get startDate => getDates().$1;
  DateTime? get endDate => getDates().$2;

  /// Returns the duration of the current period state. Will return null
  /// if the `startDate` or the `endDate` of this period are null.
  Duration? get periodStateDuration {
    final start = startDate;
    final end = endDate;

    if (start == null || end == null) {
      return null;
    }
    // Original logic assumes endDate is inclusive, add 1 day for difference
    return end.difference(start) + const Duration(days: 1);
  }

  /// Given the current period status, return the dates of the next period
  (DateTime? fromDate, DateTime? toDate) getNextDates() {
    return getDates(periodModifier: periodModifier + 1);
  }

  /// Given the current period status, return the dates of the previous period
  (DateTime? fromDate, DateTime? toDate) getPrevDates() {
    return getDates(periodModifier: periodModifier - 1);
  }

  (DateTime? fromDate, DateTime? toDate) getDatesForPeriodModifier(
      {int? periodModifier}) {
    periodModifier ??= this.periodModifier;

    return getDates(periodModifier: periodModifier);
  }

  /// Get the dates of the current period status
  /// Returns (startDate, endDateInclusive)
  (DateTime? fromDate, DateTime? toDate) getDates({int? periodModifier}) {
    periodModifier ??= this.periodModifier;

    if (datePeriod.periodType == PeriodType.cycle) {
      // Use DateUtils.dateOnly for a consistent 'now' reference day
      final now = DateUtils.dateOnly(DateTime.now());
      final currentYear = now.year;
      final currentMonth = now.month;
      final currentDayOfMonth = now.day;

      switch (datePeriod.periodicity) {
        case Periodicity.year:
          return (
            DateUtils.dateOnly(DateTime(currentYear + periodModifier, 1, 1)),
            _setEndOfDay(DateTime(currentYear + periodModifier, 12, 31))
          );

        case Periodicity.month:
          final targetBaseMonth = currentMonth + periodModifier;
          final targetYear = currentYear;

          final startDate = _calculatePeriodStart(
              targetYear, targetBaseMonth, this.startOfMonthDay);

          final nextPeriodBaseMonth = targetBaseMonth + 1;
          final nextPeriodStartDate = _calculatePeriodStart(
              targetYear, nextPeriodBaseMonth, this.startOfMonthDay);

          final endDateInclusive =
              nextPeriodStartDate.subtract(const Duration(days: 1));

          return (startDate, _setEndOfDay(endDateInclusive));

        case Periodicity.week:
          // ----- Focus on fixing this case -----
          // Calculate days to subtract to get to the start of the *current* week based on preference
          // `startOfWeek` is 1-7 (Mon-Sun), `now.weekday` is also 1-7
          final daysSinceStartOfWeek =
              (now.weekday - this.startOfWeek + DateTime.daysPerWeek) %
                  DateTime.daysPerWeek;

          // Start date of the *current* week (already DateOnly because 'now' is)
          final currentWeekStartDate =
              now.subtract(Duration(days: daysSinceStartOfWeek));

          // Apply the period modifier to get the start date of the target week
          final targetWeekStartDate = currentWeekStartDate
              .add(Duration(days: periodModifier * DateTime.daysPerWeek));

          // The inclusive end date is 6 days after the start date
          final targetWeekEndDate =
              targetWeekStartDate.add(const Duration(days: 6));

          return (targetWeekStartDate, _setEndOfDay(targetWeekEndDate));
        // ----- End of fix -----

        case Periodicity.day:
          final targetDate = DateUtils.dateOnly(DateTime(
              currentYear, currentMonth, currentDayOfMonth + periodModifier));
          return (targetDate, _setEndOfDay(targetDate));

        default:
          return (null, null);
      }
    } else if (datePeriod.periodType == PeriodType.dateRange) {
      if (datePeriod.customDateRange.$1 == null ||
          datePeriod.customDateRange.$2 == null) {
        return (null, null);
      }

      final baseDuration = datePeriod.customDateRange.$2!
          .difference(datePeriod.customDateRange.$1!);
      final offsetDuration =
          Duration(days: baseDuration.inDays * periodModifier);

      return (
        DateUtils.dateOnly(datePeriod.customDateRange.$1!.add(offsetDuration)),
        _setEndOfDay(DateUtils.dateOnly(
            datePeriod.customDateRange.$2!.add(offsetDuration)))
      );
    } else if (datePeriod.periodType == PeriodType.lastDays) {
      final now = DateUtils.dateOnly(DateTime.now());
      final currentYear = now.year;
      final currentMonth = now.month;
      final currentDayOfMonth = now.day;

      final endDate = DateUtils.dateOnly(DateTime(currentYear, currentMonth,
          currentDayOfMonth + periodModifier * datePeriod.lastDays));
      final startDate =
          endDate.subtract(Duration(days: datePeriod.lastDays - 1));

      return (startDate, _setEndOfDay(endDate));
    } else if (datePeriod.periodType == PeriodType.allTime) {
      return (null, null);
    }

    return (null, null);
  }

  String getText(BuildContext context, {bool showLongMonth = true}) {
    final localStartDate = startDate;
    final localEndDate = endDate;

    // Use yMMMMd for consistency when showing year, month, and day.
    // Use MMMd when year is current and known.
    String defaultFormatting() {
      if (localStartDate == null || localEndDate == null) {
        return datePeriod.periodType.titleText(context);
      }
      final now = DateTime.now();
      // If start and end are the same day
      if (DateUtils.isSameDay(localStartDate, localEndDate)) {
        if (localStartDate.year == now.year) {
          return DateFormat.MMMMd().format(localStartDate); // e.g., July 10
        } else {
          return DateFormat.yMMMMd()
              .format(localStartDate); // e.g., July 10, 1996
        }
      }
      // If range is within the current year
      if (localStartDate.year == now.year && localEndDate.year == now.year) {
        // Check if it spans across months
        if (localStartDate.month == localEndDate.month) {
          // Same month, different days: "July 10-15"
          return '${DateFormat.MMMd().format(localStartDate)} – ${DateFormat.MMMd().format(localEndDate)}';
        } else {
          // Different months: "Jul 10 - Aug 15"
          return '${DateFormat.MMMd().format(localStartDate)} – ${DateFormat.MMMd().format(localEndDate)}';
        }
      }
      // Default range format spanning across years or different from current year
      return '${DateFormat.yMMMd().format(localStartDate)} – ${DateFormat.yMMMd().format(localEndDate)}'; // e.g., Jul 10, 1996 - Aug 15, 1997
    }

    if (datePeriod.periodType == PeriodType.allTime) {
      return datePeriod.periodType.titleText(context);
    }

    if (localStartDate == null || localEndDate == null) {
      // Fallback if dates are somehow null despite previous check
      return datePeriod.periodType.titleText(context);
    }

    if (datePeriod.periodType == PeriodType.cycle) {
      switch (datePeriod.periodicity) {
        case Periodicity.year:
          // Keep year simple: "2023"
          return DateFormat.y().format(localStartDate);
        case Periodicity.month:
          // Consistent Month/Year formatting
          final now = DateTime.now();
          if (localStartDate.year == now.year) {
            // Current year: "July"
            return DateFormat.MMMM().format(localStartDate);
          } else {
            // Other years: "July 2022"
            return DateFormat.yMMMM().format(localStartDate);
          }
        case Periodicity.week:
          // Use the default range formatting for weeks
          return defaultFormatting();
        case Periodicity.day:
          // Use the specific day format from defaultFormatting
          return defaultFormatting();
        default:
          // Fallback for any other periodicity
          return defaultFormatting();
      }
    } else if (datePeriod.periodType == PeriodType.lastDays) {
      // Use the default range formatting for 'last N days'
      return defaultFormatting();
    } else if (datePeriod.periodType == PeriodType.dateRange) {
      // Use the default range formatting for custom ranges
      return defaultFormatting();
    } else {
      // General fallback
      return defaultFormatting();
    }
  }
}
