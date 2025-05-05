import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/hydration/hydration.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/ui/widgets/calendar/controllers/calendar_controller.dart';
import 'package:water_mind/src/ui/widgets/calendar/models/calendar_config.dart';

/// Provider for the home view model
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
  final hydrationService = ref.watch(hydrationServiceProvider);
  return HomeViewModel(hydrationService);
});

/// State for the home view model
class HomeViewModelState {
  /// User model
  final UserOnboardingModel userModel;

  /// Selected drink type
  final DrinkType? selectedDrinkType;

  /// Selected water amount
  final double? selectedAmount;

  /// Water intake history for today
  final WaterIntakeHistory todayHistory;

  /// Calendar controller
  final CalendarController calendarController;

  /// Wave animation phase
  final double wavePhase;

  /// Constructor
  HomeViewModelState({
    required this.userModel,
    this.selectedDrinkType,
    this.selectedAmount,
    required this.todayHistory,
    required this.calendarController,
    this.wavePhase = 0.0,
  });

  /// Create a copy of this state with some fields replaced
  HomeViewModelState copyWith({
    UserOnboardingModel? userModel,
    DrinkType? selectedDrinkType,
    double? selectedAmount,
    WaterIntakeHistory? todayHistory,
    CalendarController? calendarController,
    double? wavePhase,
  }) {
    return HomeViewModelState(
      userModel: userModel ?? this.userModel,
      selectedDrinkType: selectedDrinkType ?? this.selectedDrinkType,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      todayHistory: todayHistory ?? this.todayHistory,
      calendarController: calendarController ?? this.calendarController,
      wavePhase: wavePhase ?? this.wavePhase,
    );
  }
}

/// View model for the home page
class HomeViewModel extends StateNotifier<HomeViewModelState> {
  /// Hydration service
  final HydrationServiceInterface _hydrationService;

  /// UUID generator
  final _uuid = const Uuid();

  /// Timer for wave animation
  Timer? _waveTimer;

  /// Constructor
  HomeViewModel(this._hydrationService)
      : super(
          HomeViewModelState(
            userModel: const UserOnboardingModel(
              gender: Gender.male,
              weight: 70.0,
              height: 175.0,
              measureUnit: MeasureUnit.metric,
              dateOfBirth: null,
              activityLevel: ActivityLevel.moderatelyActive,
              livingEnvironment: LivingEnvironment.moderate,
              weatherCondition: WeatherCondition.cloudy,
              wakeUpTime: null,
              bedTime: null,
            ),
            todayHistory: WaterIntakeHistory(
              date: DateTime.now(),
              entries: [],
              dailyGoal: 2500, // Default goal
              measureUnit: MeasureUnit.metric,
            ),
            calendarController: CalendarController(
              config: CalendarConfig.mondayStart(),
              initialDate: DateTime.now(),
            ),
          ),
        ) {
    // Initialize
    _init();
  }

  /// Initialize the view model
  Future<void> _init() async {
    // Calculate daily goal based on user model
    _updateDailyGoal();

    // Start wave animation
    _startWaveAnimation();
  }

  /// Update the daily goal based on user model
  void _updateDailyGoal() {
    final hydrationModel =
        _hydrationService.calculateFromUserModel(state.userModel);
    
    state = state.copyWith(
      todayHistory: state.todayHistory.copyWith(
        dailyGoal: hydrationModel.dailyWaterIntake,
        measureUnit: state.userModel.measureUnit,
      ),
    );
  }

  /// Start wave animation
  void _startWaveAnimation() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      state = state.copyWith(
        wavePhase: (state.wavePhase + 0.05) % (2 * 3.14159),
      );
    });
  }

  /// Set selected drink type
  void setSelectedDrinkType(DrinkType drinkType) {
    state = state.copyWith(selectedDrinkType: drinkType);
  }

  /// Set selected water amount
  void setSelectedAmount(double amount) {
    state = state.copyWith(selectedAmount: amount);
  }

  /// Add water intake entry
  void addWaterIntakeEntry() {
    if (state.selectedDrinkType == null || state.selectedAmount == null) {
      return;
    }

    final newEntry = WaterIntakeEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      amount: state.selectedAmount!,
      drinkType: state.selectedDrinkType!,
    );

    final updatedEntries = [...state.todayHistory.entries, newEntry];

    state = state.copyWith(
      todayHistory: state.todayHistory.copyWith(
        entries: updatedEntries,
      ),
    );
  }

  /// Delete water intake entry
  void deleteWaterIntakeEntry(WaterIntakeEntry entry) {
    final updatedEntries = state.todayHistory.entries
        .where((e) => e.id != entry.id)
        .toList();

    state = state.copyWith(
      todayHistory: state.todayHistory.copyWith(
        entries: updatedEntries,
      ),
    );
  }

  /// Update user model
  void updateUserModel(UserOnboardingModel userModel) {
    state = state.copyWith(userModel: userModel);
    _updateDailyGoal();
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }
}
