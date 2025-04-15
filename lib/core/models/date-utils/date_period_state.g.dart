// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_period_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DatePeriodStateCWProxy {
  DatePeriodState datePeriod(DatePeriod datePeriod);

  DatePeriodState periodModifier(int periodModifier);

  DatePeriodState startOfMonthDay(int startOfMonthDay);

  DatePeriodState useWorkingDays(bool useWorkingDays);

  DatePeriodState startOfWeek(int startOfWeek);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DatePeriodState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DatePeriodState(...).copyWith(id: 12, name: "My name")
  /// ````
  DatePeriodState call({
    DatePeriod? datePeriod,
    int? periodModifier,
    int? startOfMonthDay,
    bool? useWorkingDays,
    int? startOfWeek,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDatePeriodState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDatePeriodState.copyWith.fieldName(...)`
class _$DatePeriodStateCWProxyImpl implements _$DatePeriodStateCWProxy {
  const _$DatePeriodStateCWProxyImpl(this._value);

  final DatePeriodState _value;

  @override
  DatePeriodState datePeriod(DatePeriod datePeriod) =>
      this(datePeriod: datePeriod);

  @override
  DatePeriodState periodModifier(int periodModifier) =>
      this(periodModifier: periodModifier);

  @override
  DatePeriodState startOfMonthDay(int startOfMonthDay) =>
      this(startOfMonthDay: startOfMonthDay);

  @override
  DatePeriodState useWorkingDays(bool useWorkingDays) =>
      this(useWorkingDays: useWorkingDays);

  @override
  DatePeriodState startOfWeek(int startOfWeek) =>
      this(startOfWeek: startOfWeek);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DatePeriodState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DatePeriodState(...).copyWith(id: 12, name: "My name")
  /// ````
  DatePeriodState call({
    Object? datePeriod = const $CopyWithPlaceholder(),
    Object? periodModifier = const $CopyWithPlaceholder(),
    Object? startOfMonthDay = const $CopyWithPlaceholder(),
    Object? useWorkingDays = const $CopyWithPlaceholder(),
    Object? startOfWeek = const $CopyWithPlaceholder(),
  }) {
    return DatePeriodState(
      datePeriod:
          datePeriod == const $CopyWithPlaceholder() || datePeriod == null
              ? _value.datePeriod
              // ignore: cast_nullable_to_non_nullable
              : datePeriod as DatePeriod,
      periodModifier: periodModifier == const $CopyWithPlaceholder() ||
              periodModifier == null
          ? _value.periodModifier
          // ignore: cast_nullable_to_non_nullable
          : periodModifier as int,
      startOfMonthDay: startOfMonthDay == const $CopyWithPlaceholder() ||
              startOfMonthDay == null
          ? _value.startOfMonthDay
          // ignore: cast_nullable_to_non_nullable
          : startOfMonthDay as int,
      useWorkingDays: useWorkingDays == const $CopyWithPlaceholder() ||
              useWorkingDays == null
          ? _value.useWorkingDays
          // ignore: cast_nullable_to_non_nullable
          : useWorkingDays as bool,
      startOfWeek:
          startOfWeek == const $CopyWithPlaceholder() || startOfWeek == null
              ? _value.startOfWeek
              // ignore: cast_nullable_to_non_nullable
              : startOfWeek as int,
    );
  }
}

extension $DatePeriodStateCopyWith on DatePeriodState {
  /// Returns a callable class that can be used as follows: `instanceOfDatePeriodState.copyWith(...)` or like so:`instanceOfDatePeriodState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DatePeriodStateCWProxy get copyWith => _$DatePeriodStateCWProxyImpl(this);
}
