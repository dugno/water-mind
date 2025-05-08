import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/services/weather/daily_weather_service.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';
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
  final weatherDataAsync = ref.watch(dailyCurrentWeatherProvider(forceRefresh: false));

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
    this.selectedDrinkType = DrinkTypes.water,
    this.selectedAmount = 200.0,
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
              config: CalendarConfig.withDashedBorders(
                locale: const Locale('vi'),
                showDateBelowCircle: false, // Hiển thị số ngày trong vòng tròn
                dashedBorderColor: Colors.blue.withOpacity(0.7),
                progressColor: Colors.blue,
                dayCircleSize: 32.0,
              ),
              initialDate: DateTime.now(),
            ),
          ),
        ) {
    // Initialize
    _init();

    // Listen for user data changes
    _ref.listen(userNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next.valueOrNull != null) {
        updateUserModel(next.value!);
      }
    });

    // Listen for weather data changes
    _ref.listen(dailyCurrentWeatherProvider(forceRefresh: false), (previous, next) {
      if (!mounted) return;
      if (next is AsyncData<NetworkResult<WeatherData>>) {
        _updateWeatherCondition(next);
      }
    });

    // Listen for today's water intake history changes
    final today = DateTime.now();
    _ref.listen(waterIntakeHistoryProvider(today), (previous, next) {
      if (!mounted) return;
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

    // Load water intake history for the week and update calendar progress
    await _updateCalendarProgress();

    // Set up calendar controller listener
    _setupCalendarListener();
  }

  /// Load today's water intake history
  Future<void> _loadTodayHistory() async {
    if (!mounted) return;

    try {
      final today = DateTime.now();
      final history = await _waterIntakeRepository.getWaterIntakeHistory(today);

      // Check if still mounted after async operation
      if (!mounted) return;

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

        // Check if still mounted after async operation
        if (!mounted) return;

        state = state.copyWith(todayHistory: newHistory);
      }
    } catch (e) {
      debugPrint('Error loading today\'s history: $e');
    }
  }

  /// Update the daily goal based on user model
  void _updateDailyGoal() {
    // Check if the notifier is mounted before updating state
    if (!mounted) return;

    try {
      final hydrationModel =
          _hydrationService.calculateFromUserModel(state.userModel);

      state = state.copyWith(
        todayHistory: state.todayHistory.copyWith(
          dailyGoal: hydrationModel.dailyWaterIntake,
          measureUnit: state.userModel.measureUnit,
        ),
      );
    } catch (e) {
      debugPrint('Error updating daily goal: $e');
    }
  }

  /// Start wave animation
  void _startWaveAnimation() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Check if the notifier is mounted before updating state
      if (!mounted) {
        timer.cancel();
        return;
      }

      state = state.copyWith(
        wavePhase: (state.wavePhase + 0.05) % (2 * 3.14159),
      );
    });
  }

  /// Set selected drink type
  void setSelectedDrinkType(DrinkType drinkType) {
    if (!mounted) return;
    state = state.copyWith(selectedDrinkType: drinkType);
  }

  /// Set selected water amount
  void setSelectedAmount(double amount) {
    if (!mounted) return;
    state = state.copyWith(selectedAmount: amount);
  }

  /// Add water intake entry
  Future<void> addWaterIntakeEntry() async {
    if (!mounted || state.selectedDrinkType == null || state.selectedAmount == null) {
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

      // Check if still mounted before updating state
      if (!mounted) return;

      // Update state
      state = state.copyWith(
        todayHistory: updatedHistory,
        isLoading: false,
      );

      // Save to repository
      await _waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);

      // Check if still mounted before refreshing provider
      if (!mounted) return;

      // Refresh the provider
      _ref.invalidate(waterIntakeHistoryProvider(DateTime.now()));

      // Cập nhật tiến trình trên lịch
      await _updateCalendarProgress();
    } catch (e) {
      debugPrint('Error adding water intake entry: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Delete water intake entry
  Future<void> deleteWaterIntakeEntry(WaterIntakeEntry entry) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true);

    try {
      // Remove from local state
      final updatedEntries = state.todayHistory.entries
          .where((e) => e.id != entry.id)
          .toList();
      final updatedHistory = state.todayHistory.copyWith(entries: updatedEntries);

      // Check if still mounted before updating state
      if (!mounted) return;

      // Update state
      state = state.copyWith(
        todayHistory: updatedHistory,
        isLoading: false,
      );

      // Save to repository
      await _waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);

      // Check if still mounted before refreshing provider
      if (!mounted) return;

      // Refresh the provider
      _ref.invalidate(waterIntakeHistoryProvider(DateTime.now()));

      // Cập nhật tiến trình trên lịch
      await _updateCalendarProgress();
    } catch (e) {
      debugPrint('Error deleting water intake entry: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Update user model
  void updateUserModel(UserOnboardingModel userModel) {
    // Check if the notifier is mounted before updating state
    if (!mounted) return;

    state = state.copyWith(userModel: userModel);
    _updateDailyGoal();
  }

  /// Update calendar progress based on water intake history
  Future<void> _updateCalendarProgress() async {
    if (!mounted) return;

    try {
      // Lấy ngày hiện tại
      final today = DateTime.now();

      // Lấy ngày đầu tiên của tuần hiện tại
      final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));

      // Lấy lịch sử uống nước cho 7 ngày trong tuần
      for (int i = 0; i < 7; i++) {
        final date = firstDayOfWeek.add(Duration(days: i));
        final history = await _waterIntakeRepository.getWaterIntakeHistory(date);

        // Kiểm tra nếu vẫn mounted sau mỗi thao tác bất đồng bộ
        if (!mounted) return;

        if (history != null) {
          // Tính toán tiến trình (tỷ lệ phần trăm hoàn thành mục tiêu hàng ngày)
          final progress = history.totalAmount / history.dailyGoal;

          // Cập nhật tiến trình trong calendar controller
          state.calendarController.updateProgressForDay(date, progress.clamp(0.0, 1.0));
        } else {
          // Nếu không có lịch sử, đặt tiến trình là 0
          state.calendarController.updateProgressForDay(date, 0.0);
        }
      }
    } catch (e) {
      debugPrint('Error updating calendar progress: $e');
    }
  }

  /// Update weather condition from network result
  void _updateWeatherCondition(AsyncData<NetworkResult<WeatherData>> weatherData) {
    // Check if the notifier is mounted before updating state
    if (!mounted) return;

    try {
      // Extract weather condition from the network result
      final weatherResult = weatherData.value;

      // Use when pattern matching to handle different states
      weatherResult.when(
        success: (data) {
          // Check if still mounted before continuing
          if (!mounted) return;

          final weatherCondition = WeatherCondition.fromCode(
            data.condition.code,
          );

          // Update user model with new weather condition
          final updatedUserModel = state.userModel.copyWith(
            weatherCondition: weatherCondition,
          );

          // Update state and recalculate water intake
          updateUserModel(updatedUserModel);

          // Also update the stored user data
          if (mounted) {
            final userNotifier = _ref.read(userNotifierProvider.notifier);
            userNotifier.updateWeatherCondition(weatherCondition);
          }
        },
        error: (error) {
          debugPrint('Error getting weather data: ${error.message}');
        },
        loading: () {
          // Do nothing while loading
        },
      );
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error updating weather condition: $e');
    }
  }

  /// Check if the notifier is still mounted
  @override
  bool get mounted => !disposed;

  /// Flag to track if the notifier has been disposed
  bool disposed = false;

  /// Set up listener for calendar controller
  void _setupCalendarListener() {
    state.calendarController.addListener(() {
      if (!mounted) return;

      // When a day is selected in the calendar, update the selected date
      if (state.calendarController.selectedDay != null) {
        final selectedDay = state.calendarController.selectedDay!;
        _loadHistoryForDate(selectedDay);
      }
    });
  }

  /// Load history for a specific date
  Future<void> _loadHistoryForDate(DateTime date) async {
    if (!mounted) return;

    try {
      final history = await _waterIntakeRepository.getWaterIntakeHistory(date);

      if (!mounted) return;

      if (history != null) {
        state = state.copyWith(todayHistory: history);
      }
    } catch (e) {
      debugPrint('Error loading history for date $date: $e');
    }
  }

  @override
  void dispose() {
    disposed = true;
    _waveTimer?.cancel();
    super.dispose();
  }
}
