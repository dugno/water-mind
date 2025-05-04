import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'hydration_model.dart';
import 'hydration_service_interface.dart';

/// Implementation of the hydration calculation service
class HydrationCalculationService implements HydrationServiceInterface {
  /// Base water intake factor in ml per kg of body weight
  static const double _baseWaterIntakeFactorMetric = 33; // 33ml per kg

  /// Base water intake factor in fl oz per lb of body weight
  static const double _baseWaterIntakeFactorImperial = 0.5; // 0.5 fl oz per lb

  /// Activity level adjustment factors
  static const Map<ActivityLevel, double> _activityFactors = {
    ActivityLevel.sedentary: 1.0,
    ActivityLevel.lightlyActive: 1.1,
    ActivityLevel.moderatelyActive: 1.2,
    ActivityLevel.veryActive: 1.3,
    ActivityLevel.extraActive: 1.4,
  };

  /// Living environment adjustment factors
  static const Map<LivingEnvironment, double> _environmentFactors = {
    LivingEnvironment.airConditioned: 1.0,
    LivingEnvironment.moderate: 1.0,
    LivingEnvironment.cold: 0.95,
    LivingEnvironment.rainyHumid: 1.1,
    LivingEnvironment.hotSunny: 1.2,
  };

  /// Gender adjustment factors
  static const Map<Gender, double> _genderFactors = {
    Gender.male: 1.0,
    Gender.female: 0.9,
    Gender.pregnant: 1.1,
    Gender.breastfeeding: 1.3,
    Gender.other: 0.95,
  };

  @override
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
  }) {
    // Default values if parameters are null
    final effectiveGender = gender ?? Gender.other;
    final effectiveWeight =
        weight ?? (measureUnit == MeasureUnit.metric ? 70.0 : 154.0);
    final effectiveActivityLevel =
        activityLevel ?? ActivityLevel.moderatelyActive;
    final effectiveLivingEnvironment =
        livingEnvironment ?? LivingEnvironment.moderate;
    final effectiveWeatherCondition =
        weatherCondition ?? WeatherCondition.cloudy;

    // Calculate age factor
    double ageFactor = 1.0;
    if (dateOfBirth != null) {
      final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
      if (age < 30) {
        ageFactor = 1.0;
      } else if (age < 55) {
        ageFactor = 0.95;
      } else {
        ageFactor = 0.9;
      }
    }

    // Calculate awake hours factor
    double awakeHoursFactor = 1.0;
    if (wakeUpTime != null && bedTime != null) {
      // Calculate hours awake
      int wakeUpMinutes = wakeUpTime.hour * 60 + wakeUpTime.minute;
      int bedTimeMinutes = bedTime.hour * 60 + bedTime.minute;

      // Handle case where bedtime is earlier than wake-up time (next day)
      if (bedTimeMinutes < wakeUpMinutes) {
        bedTimeMinutes += 24 * 60; // Add 24 hours
      }

      int awakeMinutes = bedTimeMinutes - wakeUpMinutes;
      double awakeHours = awakeMinutes / 60.0;

      // Adjust factor based on awake hours (baseline is 16 hours)
      awakeHoursFactor = awakeHours / 16.0;

      // Ensure the factor is within reasonable bounds
      awakeHoursFactor = awakeHoursFactor.clamp(0.8, 1.2);
    }

    // Base calculation
    double baseWaterIntake;
    if (measureUnit == MeasureUnit.metric) {
      baseWaterIntake = effectiveWeight * _baseWaterIntakeFactorMetric;
    } else {
      baseWaterIntake = effectiveWeight * _baseWaterIntakeFactorImperial;
    }

    // Apply adjustment factors
    final activityFactor = _activityFactors[effectiveActivityLevel] ?? 1.0;
    final environmentFactor =
        _environmentFactors[effectiveLivingEnvironment] ?? 1.0;
    final genderFactor = _genderFactors[effectiveGender] ?? 1.0;
    final weatherFactor = effectiveWeatherCondition.getHydrationFactor();

    // Calculate combined environment factor
    final combinedEnvironmentFactor = calculateCombinedEnvironmentFactor(
      effectiveLivingEnvironment,
      effectiveWeatherCondition,
      environmentFactor,
      weatherFactor,
    );

    // Calculate final water intake
    final adjustedWaterIntake = baseWaterIntake *
        activityFactor *
        combinedEnvironmentFactor * // Using combined factor instead of separate factors
        genderFactor *
        ageFactor *
        awakeHoursFactor;

    // Round to nearest 50ml or 1 fl oz
    final double roundedWaterIntake = measureUnit == MeasureUnit.metric
        ? (adjustedWaterIntake / 50).round() * 50.0
        : (adjustedWaterIntake).round().toDouble();

    // Create calculation factors map for transparency
    final calculationFactors = {
      'base': baseWaterIntake,
      'activity': activityFactor,
      'environment': combinedEnvironmentFactor, // Combined environment factor
      'gender': genderFactor,
      'age': ageFactor,
      'awakeHours': awakeHoursFactor,
      // Store original factors for reference
      '_livingEnvironment': environmentFactor,
      '_weather': weatherFactor,
    };

    return HydrationModel(
      dailyWaterIntake: roundedWaterIntake,
      measureUnit: measureUnit,
      calculationFactors: calculationFactors,
    );
  }

  @override
  HydrationModel calculateFromUserModel(UserOnboardingModel userModel) {
    return calculateDailyWaterIntake(
      gender: userModel.gender,
      weight: userModel.weight,
      height: userModel.height,
      measureUnit: userModel.measureUnit,
      dateOfBirth: userModel.dateOfBirth,
      activityLevel: userModel.activityLevel,
      livingEnvironment: userModel.livingEnvironment,
      weatherCondition: userModel.weatherCondition,
      wakeUpTime: userModel.wakeUpTime,
      bedTime: userModel.bedTime,
    );
  }

  @override
  double convertWaterVolume(double volume, MeasureUnit from, MeasureUnit to) {
    if (from == to) {
      return volume;
    }

    if (from == MeasureUnit.metric && to == MeasureUnit.imperial) {
      // Convert milliliters to fluid ounces
      return volume / 29.5735;
    } else {
      // Convert fluid ounces to milliliters
      return volume * 29.5735;
    }
  }

  /// Calculate a combined environment factor based on living environment and weather condition
  ///
  /// This method combines the living environment (long-term climate) and
  /// weather condition (current weather) into a single factor to avoid
  /// double-counting similar environmental conditions.
  ///
  /// The combined factor is weighted: 30% from living environment and 70% from weather.
  double calculateCombinedEnvironmentFactor(
    LivingEnvironment livingEnvironment,
    WeatherCondition weatherCondition,
    double environmentFactor,
    double weatherFactor,
  ) {
    // Weights for each factor (total = 1.0)
    const double livingEnvironmentWeight = 0.3; // 30% influence
    const double weatherConditionWeight = 0.7; // 70% influence

    // Check for redundant conditions to avoid double-counting
    bool isRedundant = false;

    // Check for hot/sunny redundancy
    if ((livingEnvironment == LivingEnvironment.hotSunny) &&
        (weatherCondition == WeatherCondition.hot ||
            weatherCondition == WeatherCondition.sunny ||
            weatherCondition.code == 1000)) {
      isRedundant = true;
    }

    // Check for cold redundancy
    if ((livingEnvironment == LivingEnvironment.cold) &&
        (weatherCondition.code >= 1204 && weatherCondition.code <= 1225)) {
      isRedundant = true;
    }

    // Check for rainy/humid redundancy
    if ((livingEnvironment == LivingEnvironment.rainyHumid) &&
        (weatherCondition == WeatherCondition.humid ||
            (weatherCondition.code >= 1150 && weatherCondition.code <= 1201))) {
      isRedundant = true;
    }

    // If redundant, use a modified weighting to avoid double-counting
    if (isRedundant) {
      // Use the higher factor with more weight
      final double higherFactor =
          environmentFactor > weatherFactor ? environmentFactor : weatherFactor;

      return higherFactor * 1.05; // Small boost (5%) for consistency
    } else {
      // Not redundant, use weighted average
      return (environmentFactor * livingEnvironmentWeight) +
          (weatherFactor * weatherConditionWeight);
    }
  }
}
