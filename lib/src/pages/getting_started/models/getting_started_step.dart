
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Enum representing the steps in the getting started flow
enum GettingStartedStep {
  gender,
  heightWeight,
  dateOfBirth,
  activityLevel,
  livingEnvironment,
  wakeUpTime,
  bedTime;

  /// Total number of steps in the flow
  static int get totalSteps => GettingStartedStep.values.length;

  /// Get the title for this step
  String getTitle(BuildContext context) {
    switch (this) {
      case GettingStartedStep.gender:
        return context.l10n.gender.toUpperCase();
      case GettingStartedStep.heightWeight:
        return context.l10n.heightWeight;
      case GettingStartedStep.dateOfBirth:
        return context.l10n.dateOfBirth;
      case GettingStartedStep.activityLevel:
        return context.l10n.activityLevel;
      case GettingStartedStep.livingEnvironment:
        return context.l10n.livingEnvironment;
      case GettingStartedStep.wakeUpTime:
        return context.l10n.wakeUpTime;
      case GettingStartedStep.bedTime:
        return context.l10n.bedTime;
    }
  }

  /// Get the description for this step
  String getDescription(BuildContext context) {
    switch (this) {
      case GettingStartedStep.gender:
        return context.l10n.genderDescription;
      case GettingStartedStep.heightWeight:
        return context.l10n.heightWeightDescription;
      case GettingStartedStep.dateOfBirth:
        return context.l10n.dateOfBirthDescription;
      case GettingStartedStep.activityLevel:
        return context.l10n.activityLevelDescription;
      case GettingStartedStep.livingEnvironment:
        return context.l10n.livingEnvironmentDescription;
      case GettingStartedStep.wakeUpTime:
        return context.l10n.wakeUpTimeDescription;
      case GettingStartedStep.bedTime:
        return context.l10n.bedTimeDescription;
    }
  }
}