import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/getting_started_step.dart';

part 'user_onboarding_model.freezed.dart';

/// Model representing user data collected during onboarding
@freezed
class UserOnboardingModel with _$UserOnboardingModel {
  const factory UserOnboardingModel({
    Gender? gender,
    double? height,
    double? weight,
    @Default(MeasureUnit.metric) MeasureUnit measureUnit,
    DateTime? dateOfBirth,
    ActivityLevel? activityLevel,
    LivingEnvironment? livingEnvironment,
    WeatherCondition? weatherCondition,
    TimeOfDay? wakeUpTime,
    TimeOfDay? bedTime,
    @Default(GettingStartedStep.gender) GettingStartedStep currentStep,
  }) = _UserOnboardingModel;

  const UserOnboardingModel._();

  /// Check if the current step is valid
  bool isCurrentStepValid() {
    switch (currentStep) {
      case GettingStartedStep.gender:
        return gender != null;
      case GettingStartedStep.heightWeight:
        return height != null && weight != null;
      case GettingStartedStep.dateOfBirth:
        return dateOfBirth != null;
      case GettingStartedStep.activityLevel:
        return activityLevel != null;
      case GettingStartedStep.livingEnvironment:
        return livingEnvironment != null;
      case GettingStartedStep.wakeUpTime:
        return wakeUpTime != null;
      case GettingStartedStep.bedTime:
        return bedTime != null;
    }
  }

  /// Check if the current step needs a next button
  bool needsNextButton() {
    // Only wheel picker segments need a next button
    switch (currentStep) {
      case GettingStartedStep.dateOfBirth:
      case GettingStartedStep.wakeUpTime:
      case GettingStartedStep.bedTime:
      case GettingStartedStep.heightWeight:
        return true;
      case GettingStartedStep.gender:
      case GettingStartedStep.activityLevel:
      case GettingStartedStep.livingEnvironment:
        return false;
    }
  }

  /// Check if this is the last step
  bool isLastStep() {
    return currentStep.index == GettingStartedStep.values.length - 1;
  }
}
