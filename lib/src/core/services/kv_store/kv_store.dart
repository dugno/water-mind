
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_mind/src/common/constant/strings/shared_preferences.dart';
import 'package:water_mind/src/core/theme/app_theme_data.dart';

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
  // Theme Settings
  // ----------------------

  /// Get theme style index
  static int? get themeStyleIndex =>
      sharedPreferences.getInt(SharedPreferencesConst.themeStyle);

  /// Set theme style index
  static Future<void> setThemeStyleIndex(int index) async =>
      await sharedPreferences.setInt(SharedPreferencesConst.themeStyle, index);

  /// Get theme style
  static AppThemeStyle? getThemeStyle() {
    final index = themeStyleIndex;
    if (index == null) return null;
    return AppThemeStyle.values[index];
  }

  /// Set theme style
  static Future<void> setThemeStyle(AppThemeStyle style) async =>
      await setThemeStyleIndex(style.index);

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
  static String get appLanguage =>
      sharedPreferences.getString(SharedPreferencesConst.appLanguage) ?? 'en';

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