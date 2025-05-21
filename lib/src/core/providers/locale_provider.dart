
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';

/// Provider for the app's locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  // Initialize with the stored language code
  final languageCode = KVStoreService.appLanguage;
  return LocaleNotifier(languageCode);
});

/// Notifier for managing the app's locale
class LocaleNotifier extends StateNotifier<Locale> {
  /// Constructor
  LocaleNotifier(String languageCode) : super(_localeFromLanguageCode(languageCode));

  /// Update the locale based on the language code
  Future<void> setLocale(String languageCode) async {
    // Save the language code to persistent storage
    await KVStoreService.setAppLanguage(languageCode);

    // Update the state with the new locale
    state = _localeFromLanguageCode(languageCode);
  }

  /// Convert a language code to a Locale
  static Locale _localeFromLanguageCode(String languageCode) {
    // Handle special cases for languages with country codes if needed
    switch (languageCode) {
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'zh_TW':
        return const Locale('zh', 'TW');
      default:
        return Locale(languageCode);
    }
  }
}
