import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/reminders/models/reminder_mode.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';

/// DAO cho cài đặt nhắc nhở
class ReminderSettingsDao {
  final AppDatabase _db;

  /// Constructor
  ReminderSettingsDao(this._db);

  /// Chuyển đổi từ model sang dữ liệu bảng
  ReminderSettingsTableCompanion modelToCompanion(WaterReminderModel model) {
    try {
      return ReminderSettingsTableCompanion.insert(
        id: 'water_reminder',
        enabled: Value(model.enabled),
        mode: Value(model.mode.index),
        wakeUpTime: model.wakeUpTime,
        bedTime: model.bedTime,
        intervalMinutes: Value(model.intervalMinutes),
        customTimes: Value(model.customTimes),
        disabledCustomTimes: Value(model.disabledCustomTimes),
        standardTimes: Value(model.standardTimes),
        skipIfGoalMet: Value(model.skipIfGoalMet),
        enableDoNotDisturb: Value(model.enableDoNotDisturb),
        doNotDisturbStart: Value(model.doNotDisturbStart),
        doNotDisturbEnd: Value(model.doNotDisturbEnd),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting reminder model to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  WaterReminderModel dataToModel(ReminderSettingsTableData data) {
    try {
      return WaterReminderModel(
        enabled: data.enabled,
        mode: ReminderMode.values[data.mode],
        wakeUpTime: data.wakeUpTime,
        bedTime: data.bedTime,
        intervalMinutes: data.intervalMinutes,
        customTimes: data.customTimes,
        disabledCustomTimes: data.disabledCustomTimes,
        standardTimes: data.standardTimes,
        skipIfGoalMet: data.skipIfGoalMet,
        enableDoNotDisturb: data.enableDoNotDisturb,
        doNotDisturbStart: data.doNotDisturbStart,
        doNotDisturbEnd: data.doNotDisturbEnd,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to reminder model');
      rethrow;
    }
  }

  /// Lấy cài đặt nhắc nhở
  Future<WaterReminderModel?> getReminderSettings() async {
    try {
      final data = await _db.getReminderSettings();
      if (data == null) {
        return null;
      }
      return dataToModel(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting reminder settings');
      rethrow;
    }
  }

  /// Lưu cài đặt nhắc nhở
  Future<void> saveReminderSettings(WaterReminderModel settings) async {
    try {
      await _db.saveReminderSettings(modelToCompanion(settings));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving reminder settings');
      rethrow;
    }
  }

  /// Xóa cài đặt nhắc nhở
  Future<void> clearReminderSettings() async {
    try {
      await _db.clearReminderSettings();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing reminder settings');
      rethrow;
    }
  }
}
