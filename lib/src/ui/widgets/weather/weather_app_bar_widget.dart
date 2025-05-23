import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/core/services/weather/models/forecast_data.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'package:water_mind/src/core/utils/weather/weather_icon_mapper.dart';

/// Widget to display current weather in the app bar
class WeatherAppBarWidget extends ConsumerWidget {
  /// Constructor
  const WeatherAppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the optimized provider that fetches weather data using IP-based location
    final weatherData = ref.watch(weatherAndForecastProvider());

    return weatherData.when(
      data: (result) => _buildWeatherContent(context, result),
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
      error: (_, __) => const Icon(Icons.cloud_off, color: Colors.white),
    );
  }

  Widget _buildWeatherContent(BuildContext context, NetworkResult<ForecastData> result) {
    return result.when(
      success: (data) => _buildWeatherIcon(context, data.current.condition),
      error: (error) => const Icon(Icons.cloud_off, color: Colors.white),
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(BuildContext context, WeatherCondition condition) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: WeatherIconMapper.getWeatherIconFromCondition(
            condition,
            isDay: true,
          ).svg(
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 4),
      
      ],
    );
  }
}
