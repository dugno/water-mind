import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/core/services/hydration/hydration.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_provider.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/user/user_provider.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/ui/widgets/calendar/controllers/calendar_controller.dart';
import 'package:water_mind/src/ui/widgets/calendar/models/calendar_config.dart';

/// Provider for the home view model
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
  final hydrationService = ref.watch(hydrationServiceProvider);
  final waterIntakeRepository = ref.watch(waterIntakeRepositoryProvider);

  // Watch user data
  final userDataAsync = ref.watch(userNotifierProvider);

  // Watch current weather data
  final weatherDataAsync = ref.watch(currentWeatherV2Provider(forceRefresh: false));

  // Watch today's water intake history
  final today = DateTime.now();
  final todayHistory = ref.watch(waterIntakeHistoryProvider(today));

  return HomeViewModel(
    hydrationService,
    waterIntakeRepository,
    ref,
    userDataAsync,
    weatherDataAsync,
    todayHistory,
  );
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

  /// Is loading data
  final bool isLoading;

  /// Constructor
  HomeViewModelState({
    required this.userModel,
    this.selectedDrinkType,
    this.selectedAmount,
    required this.todayHistory,
    required this.calendarController,
    this.wavePhase = 0.0,
    this.isLoading = false,
  });

  /// Create a copy of this state with some fields replaced
  HomeViewModelState copyWith({
    UserOnboardingModel? userModel,
    DrinkType? selectedDrinkType,
    double? selectedAmount,
    WaterIntakeHistory? todayHistory,
    CalendarController? calendarController,
    double? wavePhase,
    bool? isLoading,
  }) {
    return HomeViewModelState(
      userModel: userModel ?? this.userModel,
      selectedDrinkType: selectedDrinkType ?? this.selectedDrinkType,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      todayHistory: todayHistory ?? this.todayHistory,
      calendarController: calendarController ?? this.calendarController,
      wavePhase: wavePhase ?? this.wavePhase,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// View model for the home page
class HomeViewModel extends StateNotifier<HomeViewModelState> {
  /// Hydration service
  final HydrationServiceInterface _hydrationService;

  /// Water intake repository
  final WaterIntakeRepository _waterIntakeRepository;

  /// Reference to the provider container
  final Ref _ref;

  /// UUID generator
  final _uuid = const Uuid();

  /// Timer for wave animation
  Timer? _waveTimer;

  /// Constructor
  HomeViewModel(
    this._hydrationService,
    this._waterIntakeRepository,
    this._ref,
    AsyncValue<UserOnboardingModel?> userDataAsync,
    AsyncValue<dynamic> weatherDataAsync,
    AsyncValue<WaterIntakeHistory?> todayHistoryAsync,
  ) : super(
          HomeViewModelState(
            userModel: userDataAsync.valueOrNull ?? const UserOnboardingModel(
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
            todayHistory: todayHistoryAsync.valueOrNull ?? WaterIntakeHistory(
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

    // Listen for user data changes
    _ref.listen(userNotifierProvider, (previous, next) {
      if (next.valueOrNull != null) {
        updateUserModel(next.value!);
      }
    });

    // Listen for weather data changes
    _ref.listen(currentWeatherV2Provider(forceRefresh: false), (previous, next) {
      if (next.hasValue) {
        _updateWeatherCondition(next);
      }
    });

    // Listen for today's water intake history changes
    final today = DateTime.now();
    _ref.listen(waterIntakeHistoryProvider(today), (previous, next) {
      if (next.valueOrNull != null) {
        state = state.copyWith(todayHistory: next.value!);
      }
    });
  }

  /// Initialize the view model
  Future<void> _init() async {
    // Calculate daily goal based on user model
    _updateDailyGoal();

    // Start wave animation
    _startWaveAnimation();

    // Load today's water intake history
    await _loadTodayHistory();
  }

  /// Load today's water intake history
  Future<void> _loadTodayHistory() async {
    final today = DateTime.now();
    final history = await _waterIntakeRepository.getWaterIntakeHistory(today);
    
    if (history != null) {
      state = state.copyWith(todayHistory: history);
    } else {
      // If no history exists, create a new one with the calculated daily goal
      final hydrationModel = _hydrationService.calculateFromUserModel(state.userModel);
      
      final newHistory = WaterIntakeHistory(
        date: today,
        entries: [],
        dailyGoal: hydrationModel.dailyWaterIntake,
        measureUnit: state.userModel.measureUnit,
      );
      
      // Save the new history
      await _waterIntakeRepository.saveWaterIntakeHistory(newHistory);
      
      state = state.copyWith(todayHistory: newHistory);
    }
  }

  /// Update the daily goal based on user model
  void _updateDailyGoal() {
    final hydrationModel = _hydrationService.calculateFromUserModel(state.userModel);

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
  Future<void> addWaterIntakeEntry() async {
    if (state.selectedDrinkType == null || state.selectedAmount == null) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final newEntry = WaterIntakeEntry(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        amount: state.selectedAmount!,
        drinkType: state.selectedDrinkType!,
      );

      // Add to local state
      final updatedEntries = [...state.todayHistory.entries, newEntry];
      final updatedHistory = state.todayHistory.copyWith(entries: updatedEntries);
      
      // Update state
      state = state.copyWith(
        todayHistory: updatedHistory,
        isLoading: false,
      );
      
      // Save to repository
      await _waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);
      
      // Refresh the provider
      _ref.invalidate(waterIntakeHistoryProvider(DateTime.now()));
    } catch (e) {
      debugPrint('Error adding water intake entry: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Delete water intake entry
  Future<void> deleteWaterIntakeEntry(WaterIntakeEntry entry) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Remove from local state
      final updatedEntries = state.todayHistory.entries
          .where((e) => e.id != entry.id)
          .toList();
      final updatedHistory = state.todayHistory.copyWith(entries: updatedEntries);
      
      // Update state
      state = state.copyWith(
        todayHistory: updatedHistory,
        isLoading: false,
      );
      
      // Save to repository
      await _waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);
      
      // Refresh the provider
      _ref.invalidate(waterIntakeHistoryProvider(DateTime.now()));
    } catch (e) {
      debugPrint('Error deleting water intake entry: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Update user model
  void updateUserModel(UserOnboardingModel userModel) {
    state = state.copyWith(userModel: userModel);
    _updateDailyGoal();
  }

  /// Update weather condition from network result
  void _updateWeatherCondition(AsyncValue<dynamic> weatherData) {
    if (weatherData.hasValue) {
      try {
        // Extract weather condition from the network result
        final weatherResult = weatherData.value;
        if (weatherResult != null && weatherResult.data != null) {
          final weatherCondition = WeatherCondition.fromCode(
            weatherResult.data.condition.code,
          );

          // Update user model with new weather condition
          final updatedUserModel = state.userModel.copyWith(
            weatherCondition: weatherCondition,
          );

          // Update state and recalculate water intake
          updateUserModel(updatedUserModel);

          // Also update the stored user data
          final userNotifier = _ref.read(userNotifierProvider.notifier);
          userNotifier.updateWeatherCondition(weatherCondition);
        }
      } catch (e) {
        // Handle error gracefully
        debugPrint('Error updating weather condition: $e');
      }
    }
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }
}
