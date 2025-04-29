import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Helper class to access translations easily throughout the app.
///
/// This class provides static methods to access the current app localizations.
class AppLocalizationsHelper {
  /// Returns the current [AppLocalizations] instance.
  ///
  /// This method requires a [BuildContext] to access the current localizations.
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context);
  }

  /// Returns the current [AppLocalizations] instance using the [Locale].
  ///
  /// This method is useful when you need to get translations for a specific locale
  /// without having a BuildContext.
  static AppLocalizations? fromLocale(Locale locale) {
    return lookupAppLocalizations(locale);
  }
}

/// Extension on [BuildContext] to easily access translations.
extension LocalizationsExtension on BuildContext {
  /// Returns the current [AppLocalizations] instance.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
