import 'package:flutter/material.dart';

/// Configuration for the calendar widget
class CalendarConfig {
  /// The first day of the week (1 = Monday, 7 = Sunday)
  /// Default is Monday (1)
  final int firstDayOfWeek;

  /// The locale for the calendar
  /// If null, the locale from the BuildContext will be used
  final Locale? locale;

  /// Whether to show week numbers
  final bool showWeekNumbers;

  /// Whether to highlight today
  final bool highlightToday;

  /// Color for today's highlight
  final Color? todayHighlightColor;

  /// Text style for day numbers
  final TextStyle? dayTextStyle;

  /// Text style for month name
  final TextStyle? monthTextStyle;

  /// Text style for weekday names
  final TextStyle? weekdayTextStyle;

  /// Background color for selected day
  final Color? selectedDayBackgroundColor;

  /// Text color for selected day
  final Color? selectedDayTextColor;

  /// Background color for weekend days
  final Color? weekendBackgroundColor;

  /// Text color for weekend days
  final Color? weekendTextColor;

  /// Whether to use dashed borders for day circles
  final bool useDashedBorders;

  /// Color for dashed borders
  final Color? dashedBorderColor;

  /// Width for dashed borders
  final double dashedBorderWidth;

  /// Dash length for dashed borders
  final double dashedBorderDashLength;

  /// Gap length for dashed borders
  final double dashedBorderGapLength;

  /// Whether to show date numbers below the circles
  final bool showDateBelowCircle;

  /// Progress indicator color
  final Color? progressColor;

  /// Size of day circles
  final double dayCircleSize;


  /// Whether to enable horizontal scrolling in week view
  final bool enableWeekViewScrolling;

  /// Animation duration for view transitions
  final Duration animationDuration;

  /// Constructor
  const CalendarConfig({
    this.firstDayOfWeek = 1, // Monday by default
    this.locale,
    this.showWeekNumbers = false,
    this.highlightToday = true,
    this.todayHighlightColor,
    this.dayTextStyle,
    this.monthTextStyle,
    this.weekdayTextStyle,
    this.selectedDayBackgroundColor,
    this.selectedDayTextColor,
    this.weekendBackgroundColor,
    this.weekendTextColor,
    this.useDashedBorders = false,
    this.dashedBorderColor,
    this.dashedBorderWidth = 1.0,
    this.dashedBorderDashLength = 5.0,
    this.dashedBorderGapLength = 3.0,
    this.showDateBelowCircle = false,
    this.progressColor,
    this.dayCircleSize = 36.0,
    this.enableWeekViewScrolling = true,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : assert(firstDayOfWeek >= 1 && firstDayOfWeek <= 7,
            'First day of week must be between 1 (Monday) and 7 (Sunday)');

  /// Create a copy of this config with some fields replaced
  CalendarConfig copyWith({
    int? firstDayOfWeek,
    Locale? locale,
    bool? showWeekNumbers,
    bool? highlightToday,
    Color? todayHighlightColor,
    TextStyle? dayTextStyle,
    TextStyle? monthTextStyle,
    TextStyle? weekdayTextStyle,
    Color? selectedDayBackgroundColor,
    Color? selectedDayTextColor,
    Color? weekendBackgroundColor,
    Color? weekendTextColor,
    bool? useDashedBorders,
    Color? dashedBorderColor,
    double? dashedBorderWidth,
    double? dashedBorderDashLength,
    double? dashedBorderGapLength,
    bool? showDateBelowCircle,
    Color? progressColor,
    double? dayCircleSize,
    bool? enableWeekViewScrolling,
    Duration? animationDuration,
  }) {
    return CalendarConfig(
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      locale: locale ?? this.locale,
      showWeekNumbers: showWeekNumbers ?? this.showWeekNumbers,
      highlightToday: highlightToday ?? this.highlightToday,
      todayHighlightColor: todayHighlightColor ?? this.todayHighlightColor,
      dayTextStyle: dayTextStyle ?? this.dayTextStyle,
      monthTextStyle: monthTextStyle ?? this.monthTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      selectedDayBackgroundColor: selectedDayBackgroundColor ?? this.selectedDayBackgroundColor,
      selectedDayTextColor: selectedDayTextColor ?? this.selectedDayTextColor,
      weekendBackgroundColor: weekendBackgroundColor ?? this.weekendBackgroundColor,
      weekendTextColor: weekendTextColor ?? this.weekendTextColor,
      useDashedBorders: useDashedBorders ?? this.useDashedBorders,
      dashedBorderColor: dashedBorderColor ?? this.dashedBorderColor,
      dashedBorderWidth: dashedBorderWidth ?? this.dashedBorderWidth,
      dashedBorderDashLength: dashedBorderDashLength ?? this.dashedBorderDashLength,
      dashedBorderGapLength: dashedBorderGapLength ?? this.dashedBorderGapLength,
      showDateBelowCircle: showDateBelowCircle ?? this.showDateBelowCircle,
      progressColor: progressColor ?? this.progressColor,
      dayCircleSize: dayCircleSize ?? this.dayCircleSize,
      enableWeekViewScrolling: enableWeekViewScrolling ?? this.enableWeekViewScrolling,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Create a config with Sunday as the first day of the week
  factory CalendarConfig.sundayStart({
    Locale? locale,
    bool showWeekNumbers = false,
    bool highlightToday = true,
    Color? todayHighlightColor,
    TextStyle? dayTextStyle,
    TextStyle? monthTextStyle,
    TextStyle? weekdayTextStyle,
    Color? selectedDayBackgroundColor,
    Color? selectedDayTextColor,
    Color? weekendBackgroundColor,
    Color? weekendTextColor,
    bool useDashedBorders = false,
    Color? dashedBorderColor,
    double dashedBorderWidth = 1.0,
    double dashedBorderDashLength = 5.0,
    double dashedBorderGapLength = 3.0,
    bool showDateBelowCircle = false,
    Color? progressColor,
    double dayCircleSize = 36.0,
    bool enableWeekViewScrolling = true,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return CalendarConfig(
      firstDayOfWeek: 7, // Sunday
      locale: locale,
      showWeekNumbers: showWeekNumbers,
      highlightToday: highlightToday,
      todayHighlightColor: todayHighlightColor,
      dayTextStyle: dayTextStyle,
      monthTextStyle: monthTextStyle,
      weekdayTextStyle: weekdayTextStyle,
      selectedDayBackgroundColor: selectedDayBackgroundColor,
      selectedDayTextColor: selectedDayTextColor,
      weekendBackgroundColor: weekendBackgroundColor,
      weekendTextColor: weekendTextColor,
      useDashedBorders: useDashedBorders,
      dashedBorderColor: dashedBorderColor,
      dashedBorderWidth: dashedBorderWidth,
      dashedBorderDashLength: dashedBorderDashLength,
      dashedBorderGapLength: dashedBorderGapLength,
      showDateBelowCircle: showDateBelowCircle,
      progressColor: progressColor,
      dayCircleSize: dayCircleSize,
      enableWeekViewScrolling: enableWeekViewScrolling,
      animationDuration: animationDuration,
    );
  }

  /// Create a config with Monday as the first day of the week
  factory CalendarConfig.mondayStart({
    Locale? locale,
    bool showWeekNumbers = false,
    bool highlightToday = true,
    Color? todayHighlightColor,
    TextStyle? dayTextStyle,
    TextStyle? monthTextStyle,
    TextStyle? weekdayTextStyle,
    Color? selectedDayBackgroundColor,
    Color? selectedDayTextColor,
    Color? weekendBackgroundColor,
    Color? weekendTextColor,
    bool useDashedBorders = false,
    Color? dashedBorderColor,
    double dashedBorderWidth = 1.0,
    double dashedBorderDashLength = 5.0,
    double dashedBorderGapLength = 3.0,
    bool showDateBelowCircle = false,
    Color? progressColor,
    double dayCircleSize = 36.0,
    bool enableWeekViewScrolling = true,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return CalendarConfig(
      firstDayOfWeek: 1, // Monday
      locale: locale,
      showWeekNumbers: showWeekNumbers,
      highlightToday: highlightToday,
      todayHighlightColor: todayHighlightColor,
      dayTextStyle: dayTextStyle,
      monthTextStyle: monthTextStyle,
      weekdayTextStyle: weekdayTextStyle,
      selectedDayBackgroundColor: selectedDayBackgroundColor,
      selectedDayTextColor: selectedDayTextColor,
      weekendBackgroundColor: weekendBackgroundColor,
      weekendTextColor: weekendTextColor,
      useDashedBorders: useDashedBorders,
      dashedBorderColor: dashedBorderColor,
      dashedBorderWidth: dashedBorderWidth,
      dashedBorderDashLength: dashedBorderDashLength,
      dashedBorderGapLength: dashedBorderGapLength,
      showDateBelowCircle: showDateBelowCircle,
      progressColor: progressColor,
      dayCircleSize: dayCircleSize,
      enableWeekViewScrolling: enableWeekViewScrolling,
      animationDuration: animationDuration,
    );
  }

  /// Create a config with dashed borders for day circles
  factory CalendarConfig.withDashedBorders({
    int firstDayOfWeek = 1,
    Locale? locale,
    bool showWeekNumbers = false,
    bool highlightToday = true,
    Color? todayHighlightColor,
    TextStyle? dayTextStyle,
    TextStyle? monthTextStyle,
    TextStyle? weekdayTextStyle,
    Color? selectedDayBackgroundColor,
    Color? selectedDayTextColor,
    Color? weekendBackgroundColor,
    Color? weekendTextColor,
    Color? dashedBorderColor,
    double dashedBorderWidth = 1.0,
    double dashedBorderDashLength = 5.0,
    double dashedBorderGapLength = 3.0,
    bool showDateBelowCircle = true,
    Color? progressColor,
    double dayCircleSize = 36.0,
    bool enableWeekViewScrolling = true,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return CalendarConfig(
      firstDayOfWeek: firstDayOfWeek,
      locale: locale,
      showWeekNumbers: showWeekNumbers,
      highlightToday: highlightToday,
      todayHighlightColor: todayHighlightColor,
      dayTextStyle: dayTextStyle,
      monthTextStyle: monthTextStyle,
      weekdayTextStyle: weekdayTextStyle,
      selectedDayBackgroundColor: selectedDayBackgroundColor,
      selectedDayTextColor: selectedDayTextColor,
      weekendBackgroundColor: weekendBackgroundColor,
      weekendTextColor: weekendTextColor,
      useDashedBorders: true,
      dashedBorderColor: dashedBorderColor,
      dashedBorderWidth: dashedBorderWidth,
      dashedBorderDashLength: dashedBorderDashLength,
      dashedBorderGapLength: dashedBorderGapLength,
      showDateBelowCircle: showDateBelowCircle,
      progressColor: progressColor,
      dayCircleSize: dayCircleSize,
      enableWeekViewScrolling: enableWeekViewScrolling,
      animationDuration: animationDuration,
    );
  }
}
