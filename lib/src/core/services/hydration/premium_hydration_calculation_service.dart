import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/premium/premium_service.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'hydration_calculation_service.dart';
import 'hydration_model.dart';
import 'hydration_service_interface.dart';

/// Premium implementation of the hydration calculation service
/// This service checks if premium is active before using weather data
class PremiumHydrationCalculationService implements HydrationServiceInterface {
  final HydrationCalculationService _baseService;
  final PremiumService _premiumService;

  /// Constructor
  PremiumHydrationCalculationService(this._baseService, this._premiumService);

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
    // For synchronous method, we'll use a cached premium status or default to false
    // In a real implementation, you would use a cached value that's updated periodically
    bool isPremiumActive = false;
    try {
      // Try to get the cached premium status synchronously
      // This is a simplified approach - in a real app, you'd use a properly cached value
      isPremiumActive = _premiumService.isPremiumActiveSync();
    } catch (e) {
      // If there's an error, default to false
      isPremiumActive = false;
    }

    // If premium is not active, ignore weather condition
    if (!isPremiumActive) {
      weatherCondition = WeatherCondition.cloudy; // Default weather condition
    }

    // Use the base service for calculation
    return _baseService.calculateDailyWaterIntake(
      gender: gender,
      weight: weight,
      height: height,
      measureUnit: measureUnit,
      dateOfBirth: dateOfBirth,
      activityLevel: activityLevel,
      livingEnvironment: livingEnvironment,
      weatherCondition: weatherCondition,
      wakeUpTime: wakeUpTime,
      bedTime: bedTime,
    );
  }

  @override
  HydrationModel calculateFromUserModel(UserOnboardingModel userModel) {
    // For synchronous method, we'll use a cached premium status or default to false
    bool isPremiumActive = false;
    try {
      // Try to get the cached premium status synchronously
      isPremiumActive = _premiumService.isPremiumActiveSync();
    } catch (e) {
      // If there's an error, default to false
      isPremiumActive = false;
    }

    // If premium is not active, create a copy of the user model without weather condition
    if (!isPremiumActive) {
      final userModelWithoutWeather = userModel.copyWith(
        weatherCondition: WeatherCondition.cloudy, // Default weather condition
      );
      return _baseService.calculateFromUserModel(userModelWithoutWeather);
    }

    // Use the base service for calculation with original user model
    return _baseService.calculateFromUserModel(userModel);
  }

  @override
  double convertWaterVolume(double volume, MeasureUnit from, MeasureUnit to) {
    // This method doesn't need premium check
    return _baseService.convertWaterVolume(volume, from, to);
  }
}
