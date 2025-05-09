import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'reminder_mode.dart';
import 'standard_reminder_time.dart';

part 'water_reminder_model.freezed.dart';
part 'water_reminder_model.g.dart';

/// JSON converter for TimeOfDay
class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  /// Constructor
  const TimeOfDayConverter();

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

/// JSON converter for List<TimeOfDay>
class TimeOfDayListConverter implements JsonConverter<List<TimeOfDay>, List<dynamic>> {
  /// Constructor
  const TimeOfDayListConverter();

  @override
  List<TimeOfDay> fromJson(List<dynamic> json) {
    return json.map((timeString) {
      final parts = (timeString as String).split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }).toList();
  }

  @override
  List<dynamic> toJson(List<TimeOfDay> object) {
    return object.map((time) => '${time.hour}:${time.minute}').toList();
  }
}

/// JSON converter for List<StandardReminderTime>
class StandardReminderTimeListConverter implements JsonConverter<List<StandardReminderTime>, List<dynamic>> {
  /// Constructor
  const StandardReminderTimeListConverter();

  @override
  List<StandardReminderTime> fromJson(List<dynamic> json) {
    return json.map((item) => StandardReminderTime.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  List<dynamic> toJson(List<StandardReminderTime> object) {
    return object.map((item) => item.toJson()).toList();
  }
}

/// Model for water reminder settings
@freezed
class WaterReminderModel with _$WaterReminderModel {
  /// Default constructor
  const factory WaterReminderModel({
    /// Whether reminders are enabled
    @Default(true) bool enabled,

    /// The reminder mode (standard, interval, custom)
    @Default(ReminderMode.standard) ReminderMode mode,

    /// Wake up time for scheduling reminders
    @TimeOfDayConverter() required TimeOfDay wakeUpTime,

    /// Bedtime for scheduling reminders
    @TimeOfDayConverter() required TimeOfDay bedTime,

    /// Interval in minutes (for interval mode)
    @Default(60) int intervalMinutes,

    /// Custom reminder times (for custom mode)
    @TimeOfDayListConverter() @Default([]) List<TimeOfDay> customTimes,

    /// Disabled custom reminder times (for custom mode)
    @TimeOfDayListConverter() @Default([]) List<TimeOfDay> disabledCustomTimes,

    /// Standard reminder times (for standard mode)
    @StandardReminderTimeListConverter() @Default([]) List<StandardReminderTime> standardTimes,

    /// Whether to skip reminders if the user has already met their daily goal
    @Default(false) bool skipIfGoalMet,

    /// Whether to show a "Do not disturb" option during certain hours
    @Default(false) bool enableDoNotDisturb,

    /// Start time for "Do not disturb" period
    @TimeOfDayConverter() TimeOfDay? doNotDisturbStart,

    /// End time for "Do not disturb" period
    @TimeOfDayConverter() TimeOfDay? doNotDisturbEnd,
  }) = _WaterReminderModel;

  /// Create from JSON
  factory WaterReminderModel.fromJson(Map<String, dynamic> json) =>
      _$WaterReminderModelFromJson(json);

  /// Private constructor for the freezed class
  const WaterReminderModel._();

  /// Create a default model with sensible defaults
  factory WaterReminderModel.defaultSettings() => const WaterReminderModel(
    wakeUpTime: TimeOfDay(hour: 7, minute: 0),
    bedTime: TimeOfDay(hour: 22, minute: 0),
  );

  /// Convert TimeOfDay to a serializable format
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  /// Parse TimeOfDay from a string
  static TimeOfDay timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
