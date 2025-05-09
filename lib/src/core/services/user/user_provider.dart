import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/services/user/user_repository.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Provider cho user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dao = ref.watch(userDataDaoProvider);
  return UserRepositoryImpl(dao);
});

/// Provider cho user data
// Sử dụng provider từ database_providers.dart

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

  /// Clear user data
  Future<void> clearUserData() async {
    try {
      await _repository.clearUserData();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for the user notifier
final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserOnboardingModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
