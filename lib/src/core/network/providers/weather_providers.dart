import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/providers/network_providers.dart';
import 'package:water_mind/src/core/network/repositories/weather_repository_v2.dart';
import 'package:water_mind/src/core/services/weather/models/forecast_data.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';
import 'package:water_mind/src/core/services/weather/weather_cache_manager.dart';

part 'weather_providers.g.dart';

/// Provider for SharedPreferences
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider for WeatherCacheManager
@riverpod
WeatherCacheManager weatherCacheManager(WeatherCacheManagerRef ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider).valueOrNull;
  if (sharedPrefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return WeatherCacheManager(sharedPrefs);
}

/// Provider for WeatherRepositoryV2
@riverpod
WeatherRepositoryV2 weatherRepositoryV2(WeatherRepositoryV2Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  final cacheManager = ref.watch(weatherCacheManagerProvider);
  return WeatherRepositoryV2Impl(dioClient, cacheManager);
}

/// Provider for current weather and forecast data
@riverpod
Future<NetworkResult<ForecastData>> weatherAndForecast(
  WeatherAndForecastRef ref, {
  bool forceRefresh = false,
}) async {
  final repository = ref.watch(weatherRepositoryV2Provider);
  return repository.getWeatherAndForecast(
    forceRefresh: forceRefresh,
  );
}

/// Provider for current weather data
@riverpod
Future<NetworkResult<WeatherData>> currentWeatherV2(
  CurrentWeatherV2Ref ref, {
  bool forceRefresh = false,
}) async {
  final repository = ref.watch(weatherRepositoryV2Provider);
  return repository.getCurrentWeather(
    forceRefresh: forceRefresh,
  );
}

/// Provider for weather forecast
@riverpod
Future<NetworkResult<List<DailyForecast>>> weatherForecastV2(
  WeatherForecastV2Ref ref, {
  int days = 3,
  bool forceRefresh = false,
}) async {
  final repository = ref.watch(weatherRepositoryV2Provider);
  return repository.getWeatherForecast(
    days: days,
    forceRefresh: forceRefresh,
  );
}
