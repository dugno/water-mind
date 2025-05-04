import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_mind/src/core/services/hydration/hydration_calculation_service.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

void main() {
  late HydrationCalculationService hydrationService;

  setUp(() {
    hydrationService = HydrationCalculationService();
  });

  group('HydrationCalculationService', () {
    test('should calculate water intake for metric units', () {
      final result = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      expect(result.measureUnit, equals(MeasureUnit.metric));
      expect(result.dailyWaterIntake, isA<double>());
      expect(result.dailyWaterIntake, greaterThan(0));
    });

    test('should calculate water intake for imperial units', () {
      final result = hydrationService.calculateDailyWaterIntake(
        gender: Gender.female,
        weight: 140.0,
        height: 5.5,
        measureUnit: MeasureUnit.imperial,
        dateOfBirth: DateTime(1995, 5, 15),
        activityLevel: ActivityLevel.lightlyActive,
        livingEnvironment: LivingEnvironment.hotSunny,
        weatherCondition: WeatherCondition.hot,
        wakeUpTime: const TimeOfDay(hour: 6, minute: 30),
        bedTime: const TimeOfDay(hour: 22, minute: 30),
      );

      expect(result.measureUnit, equals(MeasureUnit.imperial));
      expect(result.dailyWaterIntake, isA<double>());
      expect(result.dailyWaterIntake, greaterThan(0));
    });

    test('should calculate from user model', () {
      final userModel = UserOnboardingModel(
        gender: Gender.female,
        weight: 60.0,
        height: 165.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1995, 5, 15),
        activityLevel: ActivityLevel.lightlyActive,
        livingEnvironment: LivingEnvironment.hotSunny,
        weatherCondition: WeatherCondition.hot,
        wakeUpTime: const TimeOfDay(hour: 6, minute: 30),
        bedTime: const TimeOfDay(hour: 22, minute: 30),
      );

      final result = hydrationService.calculateFromUserModel(userModel);

      expect(result.measureUnit, equals(MeasureUnit.metric));
      expect(result.dailyWaterIntake, isA<double>());
      expect(result.dailyWaterIntake, greaterThan(0));
    });

    test('should convert water volume between units', () {
      const milliliters = 1000.0;
      final fluidOunces = hydrationService.convertWaterVolume(
        milliliters,
        MeasureUnit.metric,
        MeasureUnit.imperial,
      );

      expect(fluidOunces, closeTo(33.81, 0.1)); // ~33.81 fl oz in 1000ml

      final convertedBack = hydrationService.convertWaterVolume(
        fluidOunces,
        MeasureUnit.imperial,
        MeasureUnit.metric,
      );

      expect(convertedBack, closeTo(milliliters, 0.1));
    });

    test('should apply different factors based on activity level', () {
      final baseResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.sedentary,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      final activeResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.veryActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      expect(activeResult.dailyWaterIntake,
          greaterThan(baseResult.dailyWaterIntake));
    });

    test('should apply different factors based on living environment', () {
      final baseResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      final hotResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.hotSunny,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      expect(
          hotResult.dailyWaterIntake, greaterThan(baseResult.dailyWaterIntake));
    });

    test('should apply different factors based on gender', () {
      final maleResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      final breastfeedingResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.breastfeeding,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      expect(breastfeedingResult.dailyWaterIntake,
          greaterThan(maleResult.dailyWaterIntake));
    });

    test('should apply different factors based on weather condition', () {
      final baseResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.cloudy,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      final hotResult = hydrationService.calculateDailyWaterIntake(
        gender: Gender.male,
        weight: 70.0,
        height: 175.0,
        measureUnit: MeasureUnit.metric,
        dateOfBirth: DateTime(1990, 1, 1),
        activityLevel: ActivityLevel.moderatelyActive,
        livingEnvironment: LivingEnvironment.moderate,
        weatherCondition: WeatherCondition.hot,
        wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
        bedTime: const TimeOfDay(hour: 23, minute: 0),
      );

      expect(
          hotResult.dailyWaterIntake, greaterThan(baseResult.dailyWaterIntake));

      // Check that the weather factor is greater for hot weather
      final baseWeatherFactor =
          baseResult.calculationFactors['weather'] as double;
      final hotWeatherFactor =
          hotResult.calculationFactors['weather'] as double;
      expect(hotWeatherFactor, greaterThan(baseWeatherFactor));
    });
  });
}
