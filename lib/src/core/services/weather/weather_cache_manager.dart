import 'dart:convert';

import 'package:water_mind/src/core/network/config/api_config.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/weather/models/forecast_data.dart';

/// Manager for caching weather data
class WeatherCacheManager {
  /// Key for storing the last weather data
  static const String _weatherCacheKey = 'weather_cache';

  /// Constructor for WeatherCacheManager
  WeatherCacheManager();

  /// Save forecast data to cache
  Future<bool> saveForecastData(ForecastData data) async {
    final jsonData = json.encode(data.toJson());
    await KVStoreService.sharedPreferences.setString(_weatherCacheKey, jsonData);
    return true;
  }

  /// Get forecast data from cache
  ForecastData? getForecastData() {
    final jsonData = KVStoreService.sharedPreferences.getString(_weatherCacheKey);
    if (jsonData == null) {
      return null;
    }

    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;
      return ForecastData.fromJson(data);
    } catch (e) {
      // If there's an error parsing the data, return null
      return null;
    }
  }

  /// Check if the cached data is still valid
  bool isCacheValid(ForecastData? data) {
    if (data == null) {
      return false;
    }

    final now = DateTime.now();
    final lastUpdated = data.lastUpdated;
    final difference = now.difference(lastUpdated);

    // Check if the cache is still valid based on the configured duration
    return difference.inMinutes < ApiConfig.cacheDurationMinutes;
  }

  /// Clear the cache
  Future<void> clearCache() async {
    await KVStoreService.sharedPreferences.remove(_weatherCacheKey);
  }
}
