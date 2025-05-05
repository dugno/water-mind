import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:water_mind/firebase_options.dart';

/// Service for handling Firebase Remote Config
class FirebaseRemoteConfigService {
  /// Instance of Firebase Remote Config
  final FirebaseRemoteConfig _remoteConfig;

  /// Key for the weather API in Remote Config
  static const String keyWeatherApi = 'key_weatherapi';

  /// Default values for Remote Config parameters
  static final Map<String, dynamic> _defaults = {
    keyWeatherApi: 'YOUR_WEATHERAPI_KEY', // Default fallback value
  };

  /// Private constructor
  FirebaseRemoteConfigService._(this._remoteConfig);

  /// Factory method to create and initialize the service
  static Future<FirebaseRemoteConfigService> create() async {
    // Ensure Firebase is initialized
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Get Remote Config instance
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Set default values
    await remoteConfig.setDefaults(_defaults);

    // Configure fetch settings
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      // In development, fetch more frequently
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: kDebugMode
          ? const Duration(minutes: 0) // No minimum in debug mode
          : const Duration(hours: 1), // 1 hour in production
    ));

    // Fetch and activate
    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Failed to fetch remote config: $e');
      // Continue with defaults if fetch fails
    }

    return FirebaseRemoteConfigService._(remoteConfig);
  }

  /// Get the weather API key from Remote Config
  String getWeatherApiKey() {
    return _remoteConfig.getString(keyWeatherApi);
  }

  /// Refresh Remote Config values
  Future<bool> refreshConfig() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      return activated;
    } catch (e) {
      debugPrint('Failed to refresh remote config: $e');
      return false;
    }
  }
}
