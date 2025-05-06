import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:water_mind/firebase_options.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

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

  /// Constructor with RemoteConfig instance
  /// Private by default, but accessible for testing with @visibleForTesting
  @visibleForTesting
  FirebaseRemoteConfigService(this._remoteConfig);

  /// Factory method to create and initialize the service
  static Future<FirebaseRemoteConfigService> create() async {
    // Ensure Firebase is initialized
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Failed to initialize Firebase');
      rethrow;
    }

    // Get Remote Config instance
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Set default values
      await remoteConfig.setDefaults(_defaults);
      AppLogger.debug('Remote Config defaults set');

      // Configure fetch settings
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        // In development, fetch more frequently
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 0) // No minimum in debug mode
            : const Duration(hours: 1), // 1 hour in production
      ));
      AppLogger.debug('Remote Config settings configured');

      // Try fetchAndActivate first
      try {
        final activated = await remoteConfig.fetchAndActivate();
        AppLogger.debug('Remote Config fetchAndActivate completed: $activated');
      } catch (fetchAndActivateError) {
        // If fetchAndActivate fails, try separate fetch and activate
        AppLogger.warning(
          'Remote Config fetchAndActivate failed, trying separate fetch and activate',
          {'error': fetchAndActivateError.toString()}
        );

        // Fetch and activate with retry mechanism
        bool fetchSuccess = false;
        Exception? lastException;
        StackTrace? lastStackTrace;

        // Try up to 3 times with increasing delay
        for (int attempt = 1; attempt <= 3 && !fetchSuccess; attempt++) {
          try {
            // Use fetch then activate separately to better isolate issues
            await remoteConfig.fetch();
            AppLogger.debug('Remote Config fetch completed');

            final activated = await remoteConfig.activate();
            AppLogger.debug('Remote Config activated: $activated');

            fetchSuccess = true;
          } catch (e, stackTrace) {
            lastException = e is Exception ? e : Exception(e.toString());
            lastStackTrace = stackTrace;

            AppLogger.warning(
              'Remote Config fetch/activate failed (attempt $attempt/3)',
              {'error': e.toString()}
            );

            if (attempt < 3) {
              // Wait before retrying (exponential backoff)
              final delay = Duration(seconds: attempt * 2);
              AppLogger.debug('Retrying after $delay');
              await Future.delayed(delay);
            }
          }
        }

        if (!fetchSuccess && lastException != null) {
          AppLogger.reportError(
            lastException,
            lastStackTrace,
            'Failed to fetch/activate Remote Config after 3 attempts'
          );
          // Continue with defaults
          AppLogger.info('Using default Remote Config values');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Error configuring Remote Config');
      // Continue with instance but log the error
    }

    return FirebaseRemoteConfigService(remoteConfig);
  }

  /// Get the weather API key from Remote Config
  String getWeatherApiKey() {
    return _remoteConfig.getString(keyWeatherApi);
  }

  /// Refresh Remote Config values
  Future<bool> refreshConfig() async {
    try {
      // First try the combined fetchAndActivate method
      try {
        final activated = await _remoteConfig.fetchAndActivate();
        AppLogger.debug('Remote Config fetchAndActivate completed: $activated');
        return activated;
      } catch (fetchAndActivateError) {
        // If fetchAndActivate fails with "cannot parse response", try the separate methods
        AppLogger.warning(
          'Remote Config fetchAndActivate failed, trying separate fetch and activate',
          {'error': fetchAndActivateError.toString()}
        );

        // Use fetch then activate separately to better isolate issues
        await _remoteConfig.fetch();
        AppLogger.debug('Remote Config fetch completed during refresh');

        final activated = await _remoteConfig.activate();
        AppLogger.debug('Remote Config activated during refresh: $activated');

        return activated;
      }
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Failed to refresh Remote Config');
      return false;
    }
  }

  /// Get all Remote Config values as a Map for debugging
  Map<String, dynamic> getAllValues() {
    final Map<String, dynamic> values = {};
    try {
      // Add all known keys
      values[keyWeatherApi] = getWeatherApiKey();

      // Log the values for debugging
      AppLogger.debug('Remote Config values', values);
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Error getting Remote Config values');
    }
    return values;
  }
}
