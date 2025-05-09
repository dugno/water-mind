import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/services/reminders/models/reminder_mode.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';
import 'package:water_mind/src/core/services/reminders/reminder_repository.dart';

/// Provider cho reminder repository
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final dao = ref.watch(reminderSettingsDaoProvider);
  return ReminderRepositoryImpl(dao);
});

/// Provider cho reminder settings
// Sử dụng provider từ database_providers.dart

/// Notifier cho reminder settings
class ReminderNotifier extends StateNotifier<AsyncValue<WaterReminderModel?>> {
  final ReminderRepository _repository;

  ReminderNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final settings = await _repository.getReminderSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Lưu cài đặt nhắc nhở
  Future<void> saveReminderSettings(WaterReminderModel settings) async {
    try {
      await _repository.saveReminderSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Xóa cài đặt nhắc nhở
  Future<void> clearReminderSettings() async {
    try {
      await _repository.clearReminderSettings();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cập nhật trạng thái bật/tắt nhắc nhở
  Future<void> updateEnabledState(bool enabled) async {
    if (state.hasValue && state.value != null) {
      final currentSettings = state.value!;
      final updatedSettings = currentSettings.copyWith(enabled: enabled);
      await saveReminderSettings(updatedSettings);
    }
  }

  /// Cập nhật chế độ nhắc nhở
  Future<void> updateReminderMode(int mode) async {
    if (state.hasValue && state.value != null) {
      final currentSettings = state.value!;
      final updatedSettings = currentSettings.copyWith(mode: ReminderMode.values[mode]);
      await saveReminderSettings(updatedSettings);
    }
  }
}

/// Provider cho reminder notifier
final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, AsyncValue<WaterReminderModel?>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return ReminderNotifier(repository);
});
