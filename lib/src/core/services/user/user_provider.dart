import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/user/user_repository.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Provider for the user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

/// Provider for user data
final userDataProvider = FutureProvider<UserOnboardingModel?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserData();
});

/// Notifier for user data
class UserNotifier extends StateNotifier<AsyncValue<UserOnboardingModel?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _repository.getUserData();
      state = AsyncValue.data(userData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Save user data
  Future<void> saveUserData(UserOnboardingModel userData) async {
    try {
      await _repository.saveUserData(userData);
      state = AsyncValue.data(userData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update user data with weather condition
  Future<void> updateWeatherCondition(WeatherCondition weatherCondition) async {
    if (state.hasValue && state.value != null) {
      final currentData = state.value!;
      final updatedData = currentData.copyWith(
        weatherCondition: weatherCondition,
      );
      await saveUserData(updatedData);
    }
  }
}

/// Provider for the user notifier
final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserOnboardingModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
