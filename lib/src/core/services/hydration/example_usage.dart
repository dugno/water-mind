import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'hydration.dart';

/// Example of how to use the hydration calculation service
class HydrationCalculationExample extends ConsumerWidget {
  const HydrationCalculationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example 1: Calculate directly using parameters
    final hydrationService = ref.watch(hydrationServiceProvider);
    final hydrationResult = hydrationService.calculateDailyWaterIntake(
      gender: Gender.male,
      weight: 70.0,
      height: 175.0,
      measureUnit: MeasureUnit.metric,
      dateOfBirth: DateTime(1990, 1, 1),
      activityLevel: ActivityLevel.moderatelyActive,
      livingEnvironment: LivingEnvironment.moderate,
      weatherCondition: WeatherCondition.sunny,
      wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
      bedTime: const TimeOfDay(hour: 23, minute: 0),
    );

    // Example 2: Calculate using user model
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

    final hydrationFromModel = ref.watch(userHydrationProvider(userModel));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Example 1: Direct calculation'),
        Text(
            'Daily water intake: ${hydrationResult.getFormattedWaterIntake()}'),
        Text(
            'In milliliters: ${hydrationResult.waterIntakeInMilliliters.toStringAsFixed(0)} ml'),
        Text(
            'In fluid ounces: ${hydrationResult.waterIntakeInFluidOunces.toStringAsFixed(1)} fl oz'),
        const SizedBox(height: 20),
        const Text('Example 2: From user model'),
        Text(
            'Daily water intake: ${hydrationFromModel.getFormattedWaterIntake()}'),
        Text(
            'In milliliters: ${hydrationFromModel.waterIntakeInMilliliters.toStringAsFixed(0)} ml'),
        Text(
            'In fluid ounces: ${hydrationFromModel.waterIntakeInFluidOunces.toStringAsFixed(1)} fl oz'),
        const SizedBox(height: 20),
        const Text('Calculation factors:'),
        ...hydrationFromModel.calculationFactors.entries.map(
          (entry) => Text('${entry.key}: ${entry.value.toStringAsFixed(2)}'),
        ),
      ],
    );
  }
}
