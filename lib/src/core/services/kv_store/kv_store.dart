
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_mind/src/common/constant/strings/shared_preferences.dart';

/// Service for key-value storage using SharedPreferences
abstract class KVStoreService {
  static SharedPreferences? _sharedPreferences;
  static SharedPreferences get sharedPreferences => _sharedPreferences!;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // ----------------------
  // App State
  // ----------------------

  /// Check if getting started process is done
  static bool get doneGettingStarted =>
      sharedPreferences.getBool(SharedPreferencesConst.doneGettingStarted) ?? false;

  /// Set getting started process status
  static Future<void> setDoneGettingStarted(bool value) async =>
      await sharedPreferences.setBool(SharedPreferencesConst.doneGettingStarted, value);



  // ----------------------
  // Weather Cache
  // ----------------------

  /// Get weather cache as JSON string
  static String? get weatherCacheJson =>
      sharedPreferences.getString(SharedPreferencesConst.weatherCache);

  /// Set weather cache as JSON string
  static Future<void> setWeatherCacheJson(String jsonData) async =>
      await sharedPreferences.setString(SharedPreferencesConst.weatherCache, jsonData);

  /// Get last weather update timestamp
  static int get lastWeatherUpdate =>
      sharedPreferences.getInt(SharedPreferencesConst.lastWeatherUpdate) ?? 0;

  /// Set last weather update timestamp
  static Future<void> setLastWeatherUpdate(int timestamp) async =>
      await sharedPreferences.setInt(SharedPreferencesConst.lastWeatherUpdate, timestamp);

  /// Clear weather cache
  static Future<void> clearWeatherCache() async {
    await sharedPreferences.remove(SharedPreferencesConst.weatherCache);
    await sharedPreferences.remove(SharedPreferencesConst.lastWeatherUpdate);
  }

  // ----------------------
  // App Settings
  // ----------------------

  /// Get app language code
  /// If no language is set, it will try to use the device's language
  /// If the device's language is not supported, it will fallback to English
  static String get appLanguage {
    // Check if a language has been explicitly set
    final savedLanguage = sharedPreferences.getString(SharedPreferencesConst.appLanguage);
    if (savedLanguage != null) {
      return savedLanguage;
    }

    // Try to use the device's language
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceLanguage = deviceLocale.languageCode;

    // Check if the device language is supported
    // This list should match the supported locales in the app
    const supportedLanguages = [
      'en', 'vi', 'zh', 'ja', 'ro', 'es', 'fr', 'ru', 'pt', 'id', 'de', 'tr', 'ko', 'th', 'it', 'hi'
    ];

    if (supportedLanguages.contains(deviceLanguage)) {
      return deviceLanguage;
    }

    // Fallback to English
    return 'en';
  }

  /// Set app language code
  static Future<void> setAppLanguage(String languageCode) async =>
      await sharedPreferences.setString(SharedPreferencesConst.appLanguage, languageCode);

  /// Get notifications enabled status
  static bool get notificationsEnabled =>
      sharedPreferences.getBool(SharedPreferencesConst.notificationsEnabled) ?? true;

  /// Set notifications enabled status
  static Future<void> setNotificationsEnabled(bool enabled) async =>
      await sharedPreferences.setBool(SharedPreferencesConst.notificationsEnabled, enabled);

  // ----------------------
  // General Methods
  // ----------------------

  /// Clear all data
  static Future<void> clearAll() async => await sharedPreferences.clear();

  /// Get last sync time
  static int get lastSyncTime =>
      sharedPreferences.getInt(SharedPreferencesConst.lastSyncTime) ?? 0;

  /// Set last sync time
  static Future<void> setLastSyncTime(int timestamp) async =>
      await sharedPreferences.setInt(SharedPreferencesConst.lastSyncTime, timestamp);
}