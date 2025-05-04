import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/getting_started_step.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

part 'getting_started_viewmodel.g.dart';



/// Provider for the GettingStartedViewModel
@riverpod
class GettingStartedViewModel extends _$GettingStartedViewModel {
  @override
  UserOnboardingModel build(
      {GettingStartedStep initialStep = GettingStartedStep.gender}) {
    return UserOnboardingModel(currentStep: initialStep);
  }

  /// Move to the next step
  void nextStep() {
    if (state.currentStep.index < GettingStartedStep.values.length - 1) {
      state = state.copyWith(
        currentStep: GettingStartedStep.values[state.currentStep.index + 1],
      );
    }
  }

  /// Move to the previous step
  void previousStep() {
    if (state.currentStep.index > 0) {
      state = state.copyWith(
        currentStep: GettingStartedStep.values[state.currentStep.index - 1],
      );
    }
  }

  /// Update gender
  void updateGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  /// Update height, weight and measure unit
  void updateHeightWeight(double height, double weight, MeasureUnit unit) {
    state = state.copyWith(
      height: height,
      weight: weight,
      measureUnit: unit,
    );
  }

  /// Update date of birth
  void updateDateOfBirth(DateTime date) {
    state = state.copyWith(dateOfBirth: date);
  }

  /// Update activity level
  void updateActivityLevel(ActivityLevel level) {
    state = state.copyWith(activityLevel: level);
  }

  /// Update living environment
  void updateLivingEnvironment(LivingEnvironment environment) {
    state = state.copyWith(livingEnvironment: environment);
  }

  /// Update wake up time
  void updateWakeUpTime(TimeOfDay time) {
    state = state.copyWith(wakeUpTime: time);
  }

  /// Update bedtime
  void updateBedTime(TimeOfDay time) {
    state = state.copyWith(bedTime: time);
  }

  /// Complete the onboarding process
  Map<String, dynamic> completeOnboarding() {
    // Convert the model to a map that can be saved to storage
    return {
      'gender': state.gender?.name,
      'height': state.height,
      'weight': state.weight,
      'measureUnit': state.measureUnit.name,
      'dateOfBirth': state.dateOfBirth?.toIso8601String(),
      'activityLevel': state.activityLevel?.name,
      'livingEnvironment': state.livingEnvironment?.name,
      'wakeUpTime': state.wakeUpTime != null
          ? '${state.wakeUpTime!.hour}:${state.wakeUpTime!.minute}'
          : null,
      'bedTime': state.bedTime != null
          ? '${state.bedTime!.hour}:${state.bedTime!.minute}'
          : null,
    };
  }
}
