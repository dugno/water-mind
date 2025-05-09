import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'standard_reminder_time.freezed.dart';
part 'standard_reminder_time.g.dart';

/// JSON converter for TimeOfDay
class TimeOfDayJsonConverter implements JsonConverter<TimeOfDay, String> {
  /// Constructor
  const TimeOfDayJsonConverter();

  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String toJson(TimeOfDay object) {
    return '${object.hour}:${object.minute}';
  }
}

/// Model for standard reminder time
@freezed
class StandardReminderTime with _$StandardReminderTime {
  /// Default constructor
  const factory StandardReminderTime({
    /// Unique identifier for the reminder time
    required String id,

    /// The time of day for the reminder
    @TimeOfDayJsonConverter() required TimeOfDay time,

    /// Whether this reminder is enabled
    @Default(true) bool enabled,

    /// Label for this reminder (e.g., "Morning", "Afternoon", etc.)
    String? label,
  }) = _StandardReminderTime;

  /// Create from JSON
  factory StandardReminderTime.fromJson(Map<String, dynamic> json) =>
      _$StandardReminderTimeFromJson(json);
}

/// Extension methods for StandardReminderTime
extension StandardReminderTimeExtension on StandardReminderTime {
  /// Get a formatted time string (e.g., "8:00 AM")
  String getFormattedTime() {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Get the total minutes from midnight
  int getTotalMinutes() {
    return time.hour * 60 + time.minute;
  }
}

/// Generate standard reminder times based on wake up and bed times
List<StandardReminderTime> generateStandardReminderTimes(
  TimeOfDay wakeUpTime,
  TimeOfDay bedTime,
) {
  // Convert to minutes for easier calculation
  final wakeUpMinutes = wakeUpTime.hour * 60 + wakeUpTime.minute;
  final bedTimeMinutes = bedTime.hour * 60 + bedTime.minute;

  // Adjust if bedtime is before wake up time (next day)
  final adjustedBedTimeMinutes = bedTimeMinutes <= wakeUpMinutes
      ? bedTimeMinutes + 24 * 60
      : bedTimeMinutes;

  // Calculate active period in minutes
  final activePeriodMinutes = adjustedBedTimeMinutes - wakeUpMinutes;

  // Determine number of reminders based on active period
  // Roughly one reminder every 2-3 hours during active period
  final numberOfReminders = (activePeriodMinutes / 150).round().clamp(3, 8);

  // Calculate interval between reminders
  final interval = activePeriodMinutes / (numberOfReminders - 1);

  // Generate reminder times
  final List<StandardReminderTime> reminderTimes = [];

  for (int i = 0; i < numberOfReminders; i++) {
    // Calculate minutes from wake up time
    final minutesFromWakeUp = (interval * i).round();

    // Calculate actual time in minutes
    final totalMinutes = (wakeUpMinutes + minutesFromWakeUp) % (24 * 60);

    // Convert back to TimeOfDay
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;

    // Create label based on time of day
    String? label;
    if (i == 0) {
      label = 'Morning';
    } else if (i == numberOfReminders - 1) {
      label = 'Evening';
    } else if (hour >= 11 && hour <= 13) {
      label = 'Noon';
    } else if (hour >= 14 && hour <= 17) {
      label = 'Afternoon';
    }

    reminderTimes.add(
      StandardReminderTime(
        id: 'standard_${hour}_$minute',
        time: TimeOfDay(hour: hour, minute: minute),
        enabled: true,
        label: label,
      ),
    );
  }

  return reminderTimes;
}
