import 'package:water_mind/src/core/network/config/api_config.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/repositories/base_repository.dart';
import 'package:water_mind/src/core/services/weather/models/forecast_data.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';
import 'package:water_mind/src/core/services/weather/weather_cache_manager.dart';
/// Interface for weather repository
abstract class WeatherRepositoryV2 {
  /// Get current weather and forecast data
  ///
  /// This method optimizes API usage by fetching both current weather
  /// and forecast data in a single API call, and using caching to reduce
  /// the number of API calls. Uses IP-based location detection.
  Future<NetworkResult<ForecastData>> getWeatherAndForecast({
    bool forceRefresh = false,
  });

  /// Get current weather data from the cached forecast
  Future<NetworkResult<WeatherData>> getCurrentWeather({
    bool forceRefresh = false,
  });

  /// Get weather forecast from the cached forecast
  Future<NetworkResult<List<DailyForecast>>> getWeatherForecast({
    int days = 3,
    bool forceRefresh = false,
  });
}

/// Implementation of WeatherRepositoryV2
class WeatherRepositoryV2Impl extends BaseRepositoryImpl implements WeatherRepositoryV2 {
  final WeatherCacheManager _cacheManager;

  /// Constructor for WeatherRepositoryV2Impl
  WeatherRepositoryV2Impl(
    super.dioClient,
    this._cacheManager,
  );

  @override
  Future<NetworkResult<ForecastData>> getWeatherAndForecast({
    bool forceRefresh = false,
  }) async {
    // Always use IP lookup for location
    const String locationQuery = 'auto:ip';

    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedData = _cacheManager.getForecastData();

      // If we have valid cached data, return it
      if (_cacheManager.isCacheValid(cachedData)) {
        return NetworkResult.success(cachedData!);
      }
    }

    // If no valid cache or forcing refresh, make the API call
    final result = await get<ForecastData>(
      path: '/forecast.json',
      queryParameters: {
        'key': ApiConfig.apiKey,
        'q': locationQuery,
        'days': ApiConfig.maxForecastDays,
        'aqi': 'no',
        'alerts': 'no',
      },
      fromJson: (data) => ForecastData.fromWeatherApi(data),
    );

    // If successful, cache the result
    if (result is Success<ForecastData>) {
      await _cacheManager.saveForecastData(result.data);
    }

    return result;
  }

  @override
  Future<NetworkResult<WeatherData>> getCurrentWeather({
    bool forceRefresh = false,
  }) async {
    // Get the full forecast data (which includes current weather)
    final forecastResult = await getWeatherAndForecast(
      forceRefresh: forceRefresh,
    );

    // Extract the current weather data
    return forecastResult.when(
      success: (data) => NetworkResult.success(data.current),
      error: (error) => NetworkResult.error(error),
      loading: () => const NetworkResult.loading(),
    );
  }

  @override
  Future<NetworkResult<List<DailyForecast>>> getWeatherForecast({
    int days = 3,
    bool forceRefresh = false,
  }) async {
    // Ensure days is within the allowed range
    final actualDays = days.clamp(1, ApiConfig.maxForecastDays);

    // Get the full forecast data
    final forecastResult = await getWeatherAndForecast(
      forceRefresh: forceRefresh,
    );

    // Extract the forecast data
    return forecastResult.when(
      success: (data) {
        // Limit to the requested number of days
        final limitedForecast = data.forecast.take(actualDays).toList();
        return NetworkResult.success(limitedForecast);
      },
      error: (error) => NetworkResult.error(error),
      loading: () => const NetworkResult.loading(),
    );
  }
}
