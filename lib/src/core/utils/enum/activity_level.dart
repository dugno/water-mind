import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Enum representing different activity levels
enum ActivityLevel {
  /// Sedentary (little or no exercise)
  sedentary,

  /// Lightly active (light exercise/sports 1-3 days/week)
  lightlyActive,

  /// Moderately active (moderate exercise/sports 3-5 days/week)
  moderatelyActive,

  /// Very active (hard exercise/sports 6-7 days a week)
  veryActive,

  /// Extra active (very hard exercise, physical job or training twice a day)
  extraActive;

  /// Returns the localized string representation of the activity level
  String getString(BuildContext context) {
    switch (this) {
      case ActivityLevel.sedentary:
        return context.l10n.sedentary;
      case ActivityLevel.lightlyActive:
        return context.l10n.lightlyActive;
      case ActivityLevel.moderatelyActive:
        return context.l10n.moderatelyActive;
      case ActivityLevel.veryActive:
        return context.l10n.veryActive;
      case ActivityLevel.extraActive:
        return context.l10n.extraActive;
    }
  }
}
