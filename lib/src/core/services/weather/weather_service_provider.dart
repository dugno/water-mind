import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'weather_service.dart';

/// Provider for the weather service
final weatherServiceProvider = Provider<WeatherService>((ref) {
  // In a real app, you would get this from environment variables or secure storage
  const apiKey = 'YOUR_WEATHER_API_KEY';
  return WeatherService(apiKey: apiKey);
});

/// Provider for the current weather condition
final currentWeatherProvider = FutureProvider.family<WeatherCondition, String>((ref, location) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return await weatherService.getCurrentWeather(location);
});

/// Provider for the weather forecast
final forecastProvider = FutureProvider.family<List<WeatherCondition>, String>((ref, location) async {
  final weatherService = ref.watch(weatherServiceProvider);
  return await weatherService.getForecast(location);
});
