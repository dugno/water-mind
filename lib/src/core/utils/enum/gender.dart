import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

enum Gender {
  male,
  female,
  pregnant,
  breastfeeding,
  other;

  /// Returns the localized string representation of the gender
  String getString(BuildContext context) {
    switch (this) {
      case Gender.male:
        return context.l10n.male;
      case Gender.female:
        return context.l10n.female;
      case Gender.pregnant:
        return context.l10n.pregnant;
      case Gender.breastfeeding:
        return context.l10n.breastfeeding;
      case Gender.other:
        return context.l10n.other;
    }
  }
}
