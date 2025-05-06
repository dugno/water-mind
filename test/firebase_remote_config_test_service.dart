import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// A simplified version of FirebaseRemoteConfigService for testing
/// This removes dependencies on AppLogger to make testing easier
class TestFirebaseRemoteConfigService {
  /// Instance of Firebase Remote Config
  final FirebaseRemoteConfig _remoteConfig;

  /// Key for the weather API in Remote Config
  static const String keyWeatherApi = 'key_weatherapi';

  /// Default values for Remote Config parameters
  static final Map<String, dynamic> _defaults = {
    keyWeatherApi: 'YOUR_WEATHERAPI_KEY', // Default fallback value
  };

  /// Constructor with RemoteConfig instance
  TestFirebaseRemoteConfigService(this._remoteConfig);

  /// Get the weather API key from Remote Config
  String getWeatherApiKey() {
    return _remoteConfig.getString(keyWeatherApi);
  }

  /// Refresh Remote Config values
  Future<bool> refreshConfig() async {
    try {
      // Use fetch then activate separately to better isolate issues
      await _remoteConfig.fetch();
      debugPrint('Remote Config fetch completed during refresh');
      
      final activated = await _remoteConfig.activate();
      debugPrint('Remote Config activated during refresh: $activated');
      
      return activated;
    } catch (e) {
      debugPrint('Failed to refresh Remote Config: $e');
      return false;
    }
  }
  
  /// Get all Remote Config values as a Map for debugging
  Map<String, dynamic> getAllValues() {
    final Map<String, dynamic> values = {};
    try {
      // Add all known keys
      values[keyWeatherApi] = getWeatherApiKey();
    } catch (e) {
      debugPrint('Error getting Remote Config values: $e');
    }
    return values;
  }
}
