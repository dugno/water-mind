import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Enum representing different living conditions
enum LivingEnvironment {
  /// Air-conditioned environment (indoor)
  airConditioned,

  /// Hot and sunny environment
  hotSunny,

  /// Rainy and humid environment
  rainyHumid,

  /// Cold environment
  cold,

  /// Moderate environment (mild temperature)
  moderate;

  /// Returns the localized string representation of the living environment
  String getString(BuildContext context) {
    switch (this) {
      case LivingEnvironment.airConditioned:
        return context.l10n.airConditioned;
      case LivingEnvironment.hotSunny:
        return context.l10n.hotSunny;
      case LivingEnvironment.rainyHumid:
        return context.l10n.rainyHumid;
      case LivingEnvironment.cold:
        return context.l10n.cold;
      case LivingEnvironment.moderate:
        return context.l10n.moderate;
    }
  }
}
