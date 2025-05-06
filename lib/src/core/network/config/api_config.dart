import 'package:flutter/foundation.dart';

/// Configuration for API endpoints and settings
class ApiConfig {
  /// Base URL for the API
  static const String baseUrl = 'http://api.weatherapi.com/v1';

  /// API version
  static const String apiVersion = 'v1';

  /// Full API URL with version
  static String get apiUrl => baseUrl;

  /// API key for weatherapi.com - this is a placeholder
  /// The actual key should be retrieved from Firebase Remote Config
  /// using the weatherApiKeyProvider
  static const String defaultApiKey = 'YOUR_WEATHERAPI_KEY';

  /// Variable to store the API key from Remote Config
  static String? _remoteApiKey;

  /// Getter for the API key
  /// Returns the Remote Config value if available, otherwise the default
  static String get apiKey => _remoteApiKey ?? defaultApiKey;

  /// Setter for the API key from Remote Config
  static void setApiKey(String key) {
    _remoteApiKey = key;
  }

  /// Connection timeout in milliseconds
  static const int connectionTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000;

  /// Whether to enable logging
  static bool get enableLogging => kDebugMode;

  /// Cache duration in minutes (used for regular cache validation)
  static const int cacheDurationMinutes = 30;

  /// Maximum forecast days (free tier allows up to 3 days)
  static const int maxForecastDays = 3;

  /// Whether to reset cache at midnight
  static const bool resetCacheAtMidnight = true;

  /// Whether to fetch weather only once per day
  static const bool fetchWeatherOncePerDay = true;
}
