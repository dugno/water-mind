import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/providers/locale_provider.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/hydration/hydration_service_provider.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_provider.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/reminders/reminder_service_interface.dart';
import 'package:water_mind/src/core/services/reminders/reminder_service_provider.dart';
import 'package:water_mind/src/core/services/user/user_provider.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/pages/profile/models/profile_settings_model.dart';

/// Provider for profile settings
final profileSettingsProvider = StateNotifierProvider<ProfileSettingsNotifier, AsyncValue<ProfileSettingsModel>>((ref) {
  final userDataAsync = ref.watch(userNotifierProvider);
  final reminderService = ref.watch(reminderServiceProvider);
  return ProfileSettingsNotifier(userDataAsync, reminderService, ref);
});

/// Notifier for profile settings
class ProfileSettingsNotifier extends StateNotifier<AsyncValue<ProfileSettingsModel>> with HapticFeedbackMixin {
  final ReminderServiceInterface _reminderService;
  final Ref _ref;

  /// Constructor
  ProfileSettingsNotifier(AsyncValue<UserOnboardingModel?> userDataAsync, this._reminderService, this._ref)
      : super(const AsyncValue.loading()) {
    _initialize(userDataAsync);
  }

  /// Initialize the profile settings
  Future<void> _initialize(AsyncValue<UserOnboardingModel?> userDataAsync) async {
    try {
      // Try to load profile settings from storage
      final savedSettings = await _loadProfileSettings();

      // Get reminder settings for time values
      final reminderSettings = await _reminderService.getReminderSettings();

      if (savedSettings != null) {
        // Use time settings from reminder service
        final updatedSettings = savedSettings.copyWith(
          wakeUpTime: reminderSettings.wakeUpTime,
          bedTime: reminderSettings.bedTime,
        );

        state = AsyncValue.data(updatedSettings);
        await _saveProfileSettings(updatedSettings);

        // Đồng bộ daily goal nếu có
        if (updatedSettings.useCustomDailyGoal && updatedSettings.customDailyGoal != null) {
          await _syncDailyGoalWithWaterIntakeHistory(
            updatedSettings.customDailyGoal!,
            updatedSettings.measureUnit
          );
        }

        return;
      }

      // If no saved settings, create from user data
      if (userDataAsync.hasValue && userDataAsync.value != null) {
        final userData = userDataAsync.value!;

        // Use time settings from reminder service if available
        final wakeUpTime = reminderSettings.wakeUpTime;
        final bedTime = reminderSettings.bedTime;

        final settings = ProfileSettingsModel(
          gender: userData.gender,
          height: userData.height,
          weight: userData.weight,
          measureUnit: userData.measureUnit,
          dateOfBirth: userData.dateOfBirth,
          activityLevel: userData.activityLevel,
          livingEnvironment: userData.livingEnvironment,
          wakeUpTime: wakeUpTime,
          bedTime: bedTime,
          language: KVStoreService.appLanguage,
        );

        state = AsyncValue.data(settings);
        await _saveProfileSettings(settings);

        // Đồng bộ với hydration service để tính toán daily goal
        final hydrationService = _ref.read(hydrationServiceProvider);
        final hydrationModel = hydrationService.calculateFromUserModel(userData);
        await _syncDailyGoalWithWaterIntakeHistory(
          hydrationModel.dailyWaterIntake,
          hydrationModel.measureUnit
        );
      } else {
        // Default settings if no user data
        final settings = ProfileSettingsModel(
          language: KVStoreService.appLanguage,
          wakeUpTime: reminderSettings.wakeUpTime,
          bedTime: reminderSettings.bedTime,
        );

        state = AsyncValue.data(settings);
        await _saveProfileSettings(settings);
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

      // Nếu có custom daily goal, đồng bộ với đơn vị đo mới
      if (updated.useCustomDailyGoal && updated.customDailyGoal != null) {
        await _syncDailyGoalWithWaterIntakeHistory(
          updated.customDailyGoal!,
          unit
        );
      } else {
        // Nếu không có custom daily goal, tính toán lại từ hydration service
        final userData = UserOnboardingModel(
          gender: updated.gender,
          height: updated.height,
          weight: updated.weight,
          measureUnit: unit,
          dateOfBirth: updated.dateOfBirth,
          activityLevel: updated.activityLevel,
          livingEnvironment: updated.livingEnvironment,
          wakeUpTime: updated.wakeUpTime,
          bedTime: updated.bedTime,
        );

        final hydrationService = _ref.read(hydrationServiceProvider);
        final hydrationModel = hydrationService.calculateFromUserModel(userData);
        await _syncDailyGoalWithWaterIntakeHistory(
          hydrationModel.dailyWaterIntake,
          unit
        );
      }
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

      // Đồng bộ với WaterIntakeHistory
      await _syncDailyGoalWithWaterIntakeHistory(goal, settings.measureUnit);
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
  Future<void> updateLanguage(String languageCode, {WidgetRef? ref}) async {
    haptic(HapticFeedbackType.selection);
    state.whenData((settings) async {
      final updated = settings.copyWith(language: languageCode);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);

      // Update the locale using the provider if ref is provided
      if (ref != null) {
        await ref.read(localeProvider.notifier).setLocale(languageCode);
      } else {
        // Fallback to direct update if ref is not provided
        await KVStoreService.setAppLanguage(languageCode);
      }
    });
  }

  /// Update wake up time
  Future<void> updateWakeUpTime(TimeOfDay time) async {
    haptic(HapticFeedbackType.selection);

    // Cập nhật trong reminder settings trước
    final reminderSettings = await _reminderService.getReminderSettings();
    await _reminderService.saveReminderSettings(
      reminderSettings.copyWith(wakeUpTime: time)
    );

    // Sau đó cập nhật trong profile settings
    state.whenData((settings) async {
      final updated = settings.copyWith(wakeUpTime: time);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Update bed time
  Future<void> updateBedTime(TimeOfDay time) async {
    haptic(HapticFeedbackType.selection);

    // Cập nhật trong reminder settings trước
    final reminderSettings = await _reminderService.getReminderSettings();
    await _reminderService.saveReminderSettings(
      reminderSettings.copyWith(bedTime: time)
    );

    // Sau đó cập nhật trong profile settings
    state.whenData((settings) async {
      final updated = settings.copyWith(bedTime: time);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Đồng bộ hóa thời gian thức dậy từ reminder settings
  /// Chỉ cập nhật trong profile settings, không cập nhật lại reminder settings
  Future<void> syncWakeUpTime(TimeOfDay time) async {
    state.whenData((settings) async {
      final updated = settings.copyWith(wakeUpTime: time);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Đồng bộ hóa thời gian đi ngủ từ reminder settings
  /// Chỉ cập nhật trong profile settings, không cập nhật lại reminder settings
  Future<void> syncBedTime(TimeOfDay time) async {
    state.whenData((settings) async {
      final updated = settings.copyWith(bedTime: time);
      state = AsyncValue.data(updated);
      await _saveProfileSettings(updated);
    });
  }

  /// Đồng bộ daily goal với WaterIntakeHistory
  Future<void> _syncDailyGoalWithWaterIntakeHistory(double goal, MeasureUnit measureUnit) async {
    try {
      // Lấy repository
      final waterIntakeRepository = _ref.read(waterIntakeRepositoryProvider);

      // Lấy ngày hiện tại
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      // Lấy lịch sử hiện tại nếu có
      final currentHistory = await waterIntakeRepository.getWaterIntakeHistory(normalizedToday);

      if (currentHistory != null) {
        // Cập nhật daily goal với giá trị mới
        final updatedHistory = WaterIntakeHistory(
          date: currentHistory.date,
          entries: currentHistory.entries,
          dailyGoal: goal,
          measureUnit: measureUnit,
        );

        // Lưu lịch sử đã cập nhật
        await waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);
        AppLogger.info('Đã đồng bộ daily goal từ profile settings: $goal ${measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
      } else {
        // Tạo lịch sử mới với daily goal từ profile
        final newHistory = WaterIntakeHistory(
          date: normalizedToday,
          entries: [],
          dailyGoal: goal,
          measureUnit: measureUnit,
        );

        // Lưu lịch sử mới
        await waterIntakeRepository.saveWaterIntakeHistory(newHistory);
        AppLogger.info('Đã tạo lịch sử mới với daily goal từ profile settings: $goal ${measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
      }

      // Đồng bộ với tất cả các ngày khác trong lịch sử
      try {
        // Lấy tất cả lịch sử uống nước
        final allHistories = await waterIntakeRepository.getAllWaterIntakeHistory();

        // Cập nhật daily goal cho tất cả các ngày khác
        for (final history in allHistories) {
          // Bỏ qua ngày hiện tại vì đã cập nhật ở trên
          if (history.date.year == normalizedToday.year &&
              history.date.month == normalizedToday.month &&
              history.date.day == normalizedToday.day) {
            continue;
          }

          // Cập nhật daily goal với giá trị mới
          final updatedHistory = WaterIntakeHistory(
            date: history.date,
            entries: history.entries,
            dailyGoal: goal,
            measureUnit: measureUnit,
          );

          // Lưu lịch sử đã cập nhật
          await waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);
        }

        if (allHistories.length > 1) {
          AppLogger.info('Đã đồng bộ daily goal cho ${allHistories.length - 1} ngày khác');
        }
      } catch (e) {
        AppLogger.reportError(e, StackTrace.current, 'Lỗi khi đồng bộ daily goal với tất cả các ngày');
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Lỗi khi đồng bộ daily goal với WaterIntakeHistory');
    }
  }
}
