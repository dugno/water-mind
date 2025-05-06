import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/strings/shared_preferences.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/user/user_provider.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/pages/profile/models/profile_settings_model.dart';

/// Provider for profile settings
final profileSettingsProvider = StateNotifierProvider<ProfileSettingsNotifier, AsyncValue<ProfileSettingsModel>>((ref) {
  final userDataAsync = ref.watch(userNotifierProvider);
  return ProfileSettingsNotifier(userDataAsync);
});

/// Notifier for profile settings
class ProfileSettingsNotifier extends StateNotifier<AsyncValue<ProfileSettingsModel>> with HapticFeedbackMixin {
  /// Constructor
  ProfileSettingsNotifier(AsyncValue<UserOnboardingModel?> userDataAsync)
      : super(const AsyncValue.loading()) {
    _initialize(userDataAsync);
  }

  /// Initialize the profile settings
  Future<void> _initialize(AsyncValue<UserOnboardingModel?> userDataAsync) async {
    try {
      // Try to load profile settings from storage
      final savedSettings = await _loadProfileSettings();

      if (savedSettings != null) {
        state = AsyncValue.data(savedSettings);
        return;
      }

      // If no saved settings, create from user data
      if (userDataAsync.hasValue && userDataAsync.value != null) {
        final userData = userDataAsync.value!;
        final settings = ProfileSettingsModel(
          gender: userData.gender,
          height: userData.height,
          weight: userData.weight,
          measureUnit: userData.measureUnit,
          dateOfBirth: userData.dateOfBirth,
          activityLevel: userData.activityLevel,
          livingEnvironment: userData.livingEnvironment,
          wakeUpTime: userData.wakeUpTime,
          bedTime: userData.bedTime,
          language: KVStoreService.appLanguage,
        );

        state = AsyncValue.data(settings);
        await _saveProfileSettings(settings);
      } else {
        // Default settings if no user data
        final defaultSettings = ProfileSettingsModel(
          language: KVStoreService.appLanguage,
          wakeUpTime: const TimeOfDay(hour: 7, minute: 0),
          bedTime: const TimeOfDay(hour: 23, minute: 0),
        );

        state = AsyncValue.data(defaultSettings);
        await _saveProfileSettings(defaultSettings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Load profile settings from storage
  Future<ProfileSettingsModel?> _loadProfileSettings() async {
    try {
      final json = KVStoreService.sharedPreferences.getString('profile_settings');
      if (json == null) return null;

      return ProfileSettingsModel.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  /// Save profile settings to storage
  Future<void> _saveProfileSettings(ProfileSettingsModel settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      await KVStoreService.sharedPreferences.setString('profile_settings', json);
    } catch (e) {
      // Handle error
    }
  }

  /// Update gender
  Future<void> updateGender(Gender gender) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(gender: gender);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update height and weight
  Future<void> updateHeightWeight(double height, double weight, MeasureUnit unit) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(
        height: height,
        weight: weight,
        measureUnit: unit,
      );
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update daily goal
  Future<void> updateDailyGoal(double goal, bool useCustomGoal) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(
        customDailyGoal: goal,
        useCustomDailyGoal: useCustomGoal,
      );
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update sound settings
  Future<void> updateSoundEnabled(bool enabled) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(soundEnabled: enabled);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update vibration settings
  Future<void> updateVibrationEnabled(bool enabled) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(vibrationEnabled: enabled);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update language
  Future<void> updateLanguage(String languageCode) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(language: languageCode);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
      await KVStoreService.setAppLanguage(languageCode);
    });
  }

  /// Update wake up time
  Future<void> updateWakeUpTime(TimeOfDay time) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(wakeUpTime: time);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update bed time
  Future<void> updateBedTime(TimeOfDay time) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(bedTime: time);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }
}
