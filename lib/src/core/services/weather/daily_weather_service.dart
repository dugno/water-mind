import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/network/config/api_config.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/core/network/repositories/weather_repository_v2.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/weather/models/forecast_data.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';
import 'package:water_mind/src/core/services/weather/weather_cache_manager.dart';

part 'daily_weather_service.g.dart';

/// Service for managing daily weather API calls
class DailyWeatherService {
  final WeatherRepositoryV2 _repository;
  final WeatherCacheManager _cacheManager;
  Timer? _midnightTimer;

  /// Constructor
  DailyWeatherService(this._repository, this._cacheManager) {
    _scheduleMidnightReset();
  }

  /// Schedule a timer to reset cache at midnight
  void _scheduleMidnightReset() {
    // Only schedule if the feature is enabled
    if (!ApiConfig.resetCacheAtMidnight) {
      return;
    }

    // Cancel any existing timer
    _midnightTimer?.cancel();

    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Schedule the timer
    _midnightTimer = Timer(timeUntilMidnight, () {
      _resetCacheAndFetchWeather();
      // Reschedule for the next day
      _scheduleMidnightReset();
    });

    AppLogger.info('Weather cache reset scheduled for midnight (${timeUntilMidnight.inHours} hours from now)');
  }

  /// Reset cache and fetch fresh weather data
  Future<void> _resetCacheAndFetchWeather() async {
    try {
      AppLogger.info('Resetting weather cache at midnight');
      await _cacheManager.clearCache();
      await KVStoreService.clearWeatherCache();

      // Fetch fresh data
      await _fetchWeatherIfNeeded(forceRefresh: true);

      AppLogger.info('Weather cache reset and fresh data fetched successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error resetting weather cache');
      debugPrint('Error resetting weather cache: $e');
    }
  }

  /// Check if we need to fetch weather data today
  bool _shouldFetchWeatherToday() {
    // If the feature is disabled, always return false (use regular cache validation)
    if (!ApiConfig.fetchWeatherOncePerDay) {
      return false;
    }

    final lastUpdateTimestamp = KVStoreService.lastWeatherUpdate;
    if (lastUpdateTimestamp == 0) return true;

    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateTimestamp);
    final now = DateTime.now();

    // Check if the last update was on a different day
    return lastUpdate.year != now.year ||
           lastUpdate.month != now.month ||
           lastUpdate.day != now.day;
  }

  /// Fetch weather data if needed (once per day)
  Future<NetworkResult<ForecastData>> _fetchWeatherIfNeeded({bool forceRefresh = false}) async {
    if (forceRefresh || _shouldFetchWeatherToday()) {
      // Fetch fresh data
      final result = await _repository.getWeatherAndForecast(forceRefresh: true);

      // If successful, update the last update timestamp
      if (result is Success<ForecastData>) {
        await KVStoreService.setLastWeatherUpdate(DateTime.now().millisecondsSinceEpoch);
        AppLogger.info('Weather data fetched successfully for today');
      }

      return result;
    } else {
      // Use cached data
      final cachedData = _cacheManager.getForecastData();
      if (cachedData != null) {
        return NetworkResult.success(cachedData);
      } else {
        // If no cached data, fetch fresh data
        final result = await _repository.getWeatherAndForecast(forceRefresh: true);

        // If successful, update the last update timestamp
        if (result is Success<ForecastData>) {
          await KVStoreService.setLastWeatherUpdate(DateTime.now().millisecondsSinceEpoch);
          AppLogger.info('No cached weather data found, fetched fresh data');
        }

        return result;
      }
    }
  }

  /// Get weather and forecast data (once per day)
  Future<NetworkResult<ForecastData>> getWeatherAndForecast({bool forceRefresh = false}) {
    return _fetchWeatherIfNeeded(forceRefresh: forceRefresh);
  }

  /// Get current weather data (once per day)
  Future<NetworkResult<WeatherData>> getCurrentWeather({bool forceRefresh = false}) async {
    final forecastResult = await _fetchWeatherIfNeeded(forceRefresh: forceRefresh);

    return forecastResult.when(
      success: (data) => NetworkResult.success(data.current),
      error: (error) => NetworkResult.error(error),
      loading: () => const NetworkResult.loading(),
    );
  }

  /// Get weather forecast (once per day)
  Future<NetworkResult<List<DailyForecast>>> getWeatherForecast({
    int days = 3,
    bool forceRefresh = false,
  }) async {
    final forecastResult = await _fetchWeatherIfNeeded(forceRefresh: forceRefresh);

    return forecastResult.when(
      success: (data) {
        final limitedForecast = data.forecast.take(days).toList();
        return NetworkResult.success(limitedForecast);
      },
      error: (error) => NetworkResult.error(error),
      loading: () => const NetworkResult.loading(),
    );
  }

  /// Dispose the service
  void dispose() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
  }
}

/// Provider for DailyWeatherService
@riverpod
DailyWeatherService dailyWeatherService(Ref ref) {
  final repository = ref.watch(weatherRepositoryV2Provider);
  final cacheManager = ref.watch(weatherCacheManagerProvider);

  final service = DailyWeatherService(repository, cacheManager);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Provider for current weather and forecast data (once per day)
@riverpod
Future<NetworkResult<ForecastData>> dailyWeatherAndForecast(
  Ref ref, {
  bool forceRefresh = false,
}) async {
  final service = ref.watch(dailyWeatherServiceProvider);
  return service.getWeatherAndForecast(forceRefresh: forceRefresh);
}

/// Provider for current weather data (once per day)
@riverpod
Future<NetworkResult<WeatherData>> dailyCurrentWeather(
  Ref ref, {
  bool forceRefresh = false,
}) async {
  final service = ref.watch(dailyWeatherServiceProvider);
  return service.getCurrentWeather(forceRefresh: forceRefresh);
}

/// Provider for weather forecast (once per day)
@riverpod
Future<NetworkResult<List<DailyForecast>>> dailyWeatherForecast(
  Ref ref, {
  int days = 3,
  bool forceRefresh = false,
}) async {
  final service = ref.watch(dailyWeatherServiceProvider);
  return service.getWeatherForecast(days: days, forceRefresh: forceRefresh);
}
