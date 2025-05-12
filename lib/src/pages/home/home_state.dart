import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// State for the home page
class HomeState {
  /// Selected date
  final DateTime selectedDate;

  /// Today's water intake history
  final AsyncValue<WaterIntakeHistory?> todayHistory;

  /// User model
  final AsyncValue<UserOnboardingModel?> userModel;

  /// Selected drink type
  final DrinkType selectedDrinkType;

  /// Selected amount
  final double selectedAmount;

  /// Wave phase for water cup animation
  final double wavePhase;

  /// Previous water level for animation
  final double? previousWaterLevel;

  /// Calendar controller
  final ScrollController? calendarController;

  /// Is loading data
  final bool isLoading;

  /// Error message
  final String? errorMessage;

  /// Constructor
  const HomeState({
    required this.selectedDate,
    required this.todayHistory,
    required this.userModel,
    this.selectedDrinkType = DrinkTypes.water,
    this.selectedAmount = 200,
    this.wavePhase = 0.0,
    this.previousWaterLevel,
    this.calendarController,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Create a copy of this state with the given fields replaced
  HomeState copyWith({
    DateTime? selectedDate,
    AsyncValue<WaterIntakeHistory?>? todayHistory,
    AsyncValue<UserOnboardingModel?>? userModel,
    DrinkType? selectedDrinkType,
    double? selectedAmount,
    double? wavePhase,
    double? previousWaterLevel,
    ScrollController? calendarController,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      selectedDate: selectedDate ?? this.selectedDate,
      todayHistory: todayHistory ?? this.todayHistory,
      userModel: userModel ?? this.userModel,
      selectedDrinkType: selectedDrinkType ?? this.selectedDrinkType,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      wavePhase: wavePhase ?? this.wavePhase,
      previousWaterLevel: previousWaterLevel ?? this.previousWaterLevel,
      calendarController: calendarController ?? this.calendarController,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
