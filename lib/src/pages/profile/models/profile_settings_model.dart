import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

part 'profile_settings_model.freezed.dart';
part 'profile_settings_model.g.dart';

/// Model for profile settings
@freezed
class ProfileSettingsModel with _$ProfileSettingsModel {
  /// Default constructor
  const factory ProfileSettingsModel({
    // User information
    Gender? gender,
    double? height,
    double? weight,
    @Default(MeasureUnit.metric) MeasureUnit measureUnit,
    DateTime? dateOfBirth,
    ActivityLevel? activityLevel,
    LivingEnvironment? livingEnvironment,
    
    // Daily goal
    double? customDailyGoal,
    @Default(false) bool useCustomDailyGoal,
    
    // Time settings
    @TimeOfDayConverter() TimeOfDay? wakeUpTime,
    @TimeOfDayConverter() TimeOfDay? bedTime,
    
    // Sound and vibration
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    
    // App settings
    @Default('en') String language,
  }) = _ProfileSettingsModel;

  /// Factory constructor for creating a ProfileSettingsModel from JSON
  factory ProfileSettingsModel.fromJson(Map<String, dynamic> json) => 
      _$ProfileSettingsModelFromJson(json);
}

/// Converter for TimeOfDay to JSON
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
  String toJson(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }
}
