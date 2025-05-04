import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'hydration_model.dart';

/// Interface for hydration calculation services
abstract class HydrationServiceInterface {
  /// Calculate daily water intake based on user parameters
  HydrationModel calculateDailyWaterIntake({
    required Gender? gender,
    required double? weight,
    required double? height,
    required MeasureUnit measureUnit,
    required DateTime? dateOfBirth,
    required ActivityLevel? activityLevel,
    required LivingEnvironment? livingEnvironment,
    required WeatherCondition? weatherCondition,
    required TimeOfDay? wakeUpTime,
    required TimeOfDay? bedTime,
  });

  /// Calculate daily water intake from user onboarding model
  HydrationModel calculateFromUserModel(UserOnboardingModel userModel);

  /// Convert water volume between measurement units
  double convertWaterVolume(double volume, MeasureUnit from, MeasureUnit to);
}
