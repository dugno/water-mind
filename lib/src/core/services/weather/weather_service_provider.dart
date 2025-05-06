import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/network/config/api_config.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'weather_service.dart';

/// Provider for the weather service
final weatherServiceProvider = Provider<WeatherService>((ref) {
  // Use the API key from ApiConfig which is set from Firebase Remote Config
  return WeatherService(apiKey: ApiConfig.apiKey);
});

/// Provider for the current weather condition
final currentWeatherProvider = FutureProvider.family<WeatherCondition, String>((ref, location) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return await weatherService.getCurrentWeather(location);
});


