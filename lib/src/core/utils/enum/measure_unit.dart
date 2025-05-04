import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Enum representing different measurement units
enum MeasureUnit {
  /// Metric system (cm, kg)
  metric,

  /// Imperial system (ft, lbs)
  imperial;

  /// Returns the localized string representation of the measurement unit
  String getString(BuildContext context) {
    switch (this) {
      case MeasureUnit.metric:
        return context.l10n.metric;
      case MeasureUnit.imperial:
        return context.l10n.imperial;
    }
  }
}
