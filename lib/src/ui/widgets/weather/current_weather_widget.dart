import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/hydration/hydration.dart';
import 'package:water_mind/src/core/services/weather/weather.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';


/// Widget to display the current weather and its effect on water intake
class CurrentWeatherWidget extends ConsumerWidget {
  /// The location to get weather for
  final String location;

  /// The user model to calculate water intake
  final UserOnboardingModel userModel;

  /// Constructor
  const CurrentWeatherWidget({
    super.key,
    required this.location,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider(location));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weatherAsync.when(
          data: (weather) => _buildWeatherContent(context, ref, weather),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading weather: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
      BuildContext context, WidgetRef ref, WeatherCondition weather) {
    // Create a copy of the user model with the current weather
    final updatedUserModel = userModel.copyWith(weatherCondition: weather);

    // Calculate water intake with the current weather
    final hydrationService = ref.watch(hydrationServiceProvider);
    final hydrationModel =
        hydrationService.calculateFromUserModel(updatedUserModel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Current Weather in $location',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              weather.getIcon(),
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              weather.getString(context),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Recommended water intake:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          hydrationModel.getFormattedWaterIntake(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Environment factor: ×${hydrationModel.calculationFactors['environment']?.toStringAsFixed(2) ?? '1.00'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        // Show the original factors for reference
        const SizedBox(height: 4),
        Text(
          '(Weather: ×${weather.getHydrationFactor().toStringAsFixed(2)}, '
          'Living env: ×${hydrationModel.calculationFactors['_livingEnvironment']?.toStringAsFixed(2) ?? '1.00'})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
