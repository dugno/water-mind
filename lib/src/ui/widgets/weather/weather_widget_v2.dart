import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/core/services/weather/models/forecast_data.dart';
import 'package:water_mind/src/core/utils/weather/weather_icon_mapper.dart';

/// A widget that displays weather information using the optimized API
class WeatherWidgetV2 extends ConsumerWidget {
  /// Constructor for WeatherWidgetV2
  const WeatherWidgetV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the optimized provider that fetches both current and forecast data in one call
    // using IP-based location detection
    final weatherData = ref.watch(weatherAndForecastProvider());

    return weatherData.when(
      data: (result) => _buildWeatherContent(context, result),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading weather data: $error'),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, NetworkResult<ForecastData> result) {
    return result.when(
      success: (data) => _buildWeatherDisplay(context, data),
      error: (error) => Center(
        child: Text('Error: ${error.message}'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildWeatherDisplay(BuildContext context, ForecastData data) {
    final current = data.current;
    final location = data.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current weather section
        Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${location.name}, ${location.country}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current.temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Feels like: ${current.feelsLike.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          current.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: WeatherIconMapper.getWeatherIcon(
                        current.condition.code,
                        isDay: current.isDay,
                      ).svg(
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherDetail(
                      context,
                      Icons.water_drop,
                      '${current.humidity}%',
                      'Humidity',
                    ),
                    _buildWeatherDetail(
                      context,
                      Icons.air,
                      '${current.windSpeed} km/h',
                      'Wind',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Forecast section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Forecast',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.forecast.length,
            itemBuilder: (context, index) {
              final forecast = data.forecast[index];
              return _buildForecastCard(context, forecast, index == 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildForecastCard(BuildContext context, DailyForecast forecast, bool isToday) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : _formatDay(forecast.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 32,
              height: 32,
              child: WeatherIconMapper.getWeatherIcon(
                forecast.conditionCode,
                isDay: true, // Always use day icons for forecast
              ).svg(
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              forecast.conditionText,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${forecast.minTemp.toStringAsFixed(0)}°',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${forecast.maxTemp.toStringAsFixed(0)}°',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    // Return day of week
    switch (date.weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
