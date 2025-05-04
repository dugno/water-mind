import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_config.dart';
import '../models/calendar_day.dart';

/// Utility functions for working with dates in the calendar
class CalendarDateUtils {
  /// Get the first day of the month
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the last day of the month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get the first day of the week containing the given date
  static DateTime firstDayOfWeek(DateTime date, int startOfWeek) {
    // Convert to ISO weekday (1=Monday, 7=Sunday)
    int weekday = date.weekday;

    // Adjust for first day of week
    int diff = (weekday - startOfWeek) % 7;
    return date.subtract(Duration(days: diff));
  }

  /// Get the last day of the week containing the given date
  static DateTime lastDayOfWeek(DateTime date, int startOfWeek) {
    final first = firstDayOfWeek(date, startOfWeek);
    return first.add(const Duration(days: 6));
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Check if a date is a weekend (Saturday or Sunday)
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Get the week number for a date
  static int getWeekNumber(DateTime date) {
    // Get the first day of the year
    final firstDayOfYear = DateTime(date.year, 1, 1);

    // Calculate the difference in days
    final daysFromFirstDay = date.difference(firstDayOfYear).inDays;

    // Calculate the week number
    return ((daysFromFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  /// Get the days for a month view
  static List<CalendarDay> getDaysInMonthView(
    DateTime month,
    CalendarConfig config,
  ) {
    final List<CalendarDay> days = [];

    // Get the first day of the month
    final firstDay = firstDayOfMonth(month);

    // Get the first day to display (might be from the previous month)
    final firstDisplayDay = firstDayOfWeek(firstDay, config.firstDayOfWeek);

    // Get the last day of the month
    final lastDay = lastDayOfMonth(month);

    // Get the last day to display (might be from the next month)
    final lastDisplayDay = lastDayOfWeek(lastDay, config.firstDayOfWeek);

    // Current date for "today" check
    final today = DateTime.now();

    // Generate all days to display
    DateTime currentDay = firstDisplayDay;
    while (!currentDay.isAfter(lastDisplayDay)) {
      days.add(CalendarDay(
        date: currentDay,
        isCurrentMonth: currentDay.month == month.month,
        isToday: isSameDay(currentDay, today),
        isWeekend: isWeekend(currentDay),
      ));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return days;
  }

  /// Get the localized name of a month
  static String getMonthName(DateTime date, Locale locale) {
    return DateFormat.MMMM(locale.languageCode).format(date);
  }

  /// Get the localized name of a weekday
  static String getWeekdayName(int weekday, Locale locale, {bool short = false}) {
    // Create a date for the weekday (Jan 1-7, 2024 is Monday-Sunday)
    final date = DateTime(2024, 1, weekday);

    if (short) {
      return DateFormat.E(locale.languageCode).format(date);
    } else {
      return DateFormat.EEEE(locale.languageCode).format(date);
    }
  }

  /// Get the ordered list of weekdays based on the first day of the week
  static List<int> getOrderedWeekdays(int startOfWeek) {
    // Create a list of weekdays in ISO format (1-7, Monday-Sunday)
    final List<int> weekdays = List.generate(7, (index) => index + 1);

    // Reorder the list based on the first day of the week
    final int offset = startOfWeek - 1;
    final List<int> orderedWeekdays = [
      ...weekdays.sublist(offset),
      ...weekdays.sublist(0, offset),
    ];

    return orderedWeekdays;
  }
}
