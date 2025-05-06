import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/providers/repository_providers.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';

part 'weather_service_provider_v2.g.dart';

/// Provider for current weather data
@riverpod
Future<NetworkResult<WeatherData>> currentWeather(
  Ref ref, {
  required double latitude,
  required double longitude,
}) async {
  final weatherRepository = ref.watch(weatherRepositoryProvider);
  return weatherRepository.getCurrentWeather(
    latitude: latitude,
    longitude: longitude,
  );
}

/// Provider for weather forecast
@riverpod
Future<NetworkResult<List<WeatherData>>> weatherForecast(
   Ref ref, {
  required double latitude,
  required double longitude,
  required int days,
}) async {
  final weatherRepository = ref.watch(weatherRepositoryProvider);
  return weatherRepository.getWeatherForecast(
    latitude: latitude,
    longitude: longitude,
    days: days,
  );
}
