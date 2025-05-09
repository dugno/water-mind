import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/reminders/models/standard_reminder_time.dart' as reminder_models;
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// TypeConverter cho DateTime
class DateTimeConverter extends TypeConverter<DateTime, String> {
  /// Constructor
  const DateTimeConverter();

  @override
  DateTime fromSql(String fromDb) {
    return DateTime.parse(fromDb);
  }

  @override
  String toSql(DateTime value) {
    return value.toIso8601String();
  }
}

/// TypeConverter cho TimeOfDay
class TimeOfDayConverter extends TypeConverter<TimeOfDay, String> {
  /// Constructor
  const TimeOfDayConverter();

  @override
  TimeOfDay fromSql(String fromDb) {
    final parts = fromDb.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  String toSql(TimeOfDay value) {
    return '${value.hour}:${value.minute}';
  }
}

/// TypeConverter cho List<TimeOfDay>
class TimeOfDayListConverter extends TypeConverter<List<TimeOfDay>, String> {
  /// Constructor
  const TimeOfDayListConverter();

  @override
  List<TimeOfDay> fromSql(String fromDb) {
    try {
      final List<dynamic> jsonList = json.decode(fromDb) as List;
      return jsonList.map((timeString) {
        final parts = (timeString as String).split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  String toSql(List<TimeOfDay> value) {
    final jsonList = value.map((time) => '${time.hour}:${time.minute}').toList();
    return json.encode(jsonList);
  }
}

/// TypeConverter cho List<reminder_models.StandardReminderTime>
class StandardReminderTimeListConverter extends TypeConverter<List<reminder_models.StandardReminderTime>, String> {
  /// Constructor
  const StandardReminderTimeListConverter();

  @override
  List<reminder_models.StandardReminderTime> fromSql(String fromDb) {
    try {
      final List<dynamic> jsonList = json.decode(fromDb) as List;
      return jsonList
          .map((item) => reminder_models.StandardReminderTime.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  String toSql(List<reminder_models.StandardReminderTime> value) {
    final jsonList = value.map((item) => item.toJson()).toList();
    return json.encode(jsonList);
  }
}

/// TypeConverter cho MeasureUnit
class MeasureUnitConverter extends TypeConverter<MeasureUnit, int> {
  /// Constructor
  const MeasureUnitConverter();

  @override
  MeasureUnit fromSql(int fromDb) {
    return MeasureUnit.values[fromDb];
  }

  @override
  int toSql(MeasureUnit value) {
    return value.index;
  }
}

/// TypeConverter cho Gender
class GenderConverter extends TypeConverter<Gender?, int?> {
  /// Constructor
  const GenderConverter();

  @override
  Gender? fromSql(int? fromDb) {
    if (fromDb == null) return null;
    return Gender.values[fromDb];
  }

  @override
  int? toSql(Gender? value) {
    if (value == null) return null;
    return value.index;
  }
}

/// TypeConverter cho ActivityLevel
class ActivityLevelConverter extends TypeConverter<ActivityLevel?, int?> {
  /// Constructor
  const ActivityLevelConverter();

  @override
  ActivityLevel? fromSql(int? fromDb) {
    if (fromDb == null) return null;
    return ActivityLevel.values[fromDb];
  }

  @override
  int? toSql(ActivityLevel? value) {
    if (value == null) return null;
    return value.index;
  }
}

/// TypeConverter cho LivingEnvironment
class LivingEnvironmentConverter extends TypeConverter<LivingEnvironment?, int?> {
  /// Constructor
  const LivingEnvironmentConverter();

  @override
  LivingEnvironment? fromSql(int? fromDb) {
    if (fromDb == null) return null;
    return LivingEnvironment.values[fromDb];
  }

  @override
  int? toSql(LivingEnvironment? value) {
    if (value == null) return null;
    return value.index;
  }
}
