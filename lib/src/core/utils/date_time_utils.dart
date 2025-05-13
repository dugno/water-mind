import 'package:flutter/material.dart';

/// Utility class for date and time operations
class DateTimeUtils {
  // Private constructor to prevent instantiation
  DateTimeUtils._();

  /// Get the start of the week (Monday) for a given date
  static DateTime getStartOfWeek(DateTime date) {
    final day = date.weekday;
    return date.subtract(Duration(days: day - 1));
  }

  /// Get the end of the week (Sunday) for a given date
  static DateTime getEndOfWeek(DateTime date) {
    final day = date.weekday;
    return date.add(Duration(days: 7 - day));
  }

  /// Get the number of days in a month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  /// Format a TimeOfDay to a string (HH:MM)
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format a DateTime to a string (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
  }

  /// Format a DateTime to a string (HH:MM)
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format a DateTime to a string (YYYY-MM-DD HH:MM)
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// Get the day of week name
  static String getDayOfWeekName(int dayOfWeek, {bool short = false}) {
    final days = short 
      ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  /// Get the month name
  static String getMonthName(int month, {bool short = false}) {
    final months = short
      ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      : ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
