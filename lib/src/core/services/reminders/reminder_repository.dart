import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/daos/reminder_settings_dao.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';

/// Interface cho reminder repository
abstract class ReminderRepository {
  /// Lấy cài đặt nhắc nhở
  Future<WaterReminderModel?> getReminderSettings();

  /// Lưu cài đặt nhắc nhở
  Future<void> saveReminderSettings(WaterReminderModel settings);

  /// Xóa cài đặt nhắc nhở
  Future<void> clearReminderSettings();
}

/// Triển khai repository sử dụng Drift
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderSettingsDao _dao;

  /// Constructor
  ReminderRepositoryImpl(this._dao);

  @override
  Future<WaterReminderModel?> getReminderSettings() async {
    try {
      return await _dao.getReminderSettings();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting reminder settings');
      rethrow;
    }
  }

  @override
  Future<void> saveReminderSettings(WaterReminderModel settings) async {
    try {
      await _dao.saveReminderSettings(settings);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving reminder settings');
      rethrow;
    }
  }

  @override
  Future<void> clearReminderSettings() async {
    try {
      await _dao.clearReminderSettings();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing reminder settings');
      rethrow;
    }
  }
}
