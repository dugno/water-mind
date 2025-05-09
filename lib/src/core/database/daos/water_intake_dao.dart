import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// DAO cho dữ liệu uống nước
class WaterIntakeDao {
  final AppDatabase _db;

  /// Constructor
  WaterIntakeDao(this._db);

  /// Chuyển đổi từ model sang dữ liệu bảng
  WaterIntakeHistoryTableCompanion historyToCompanion(WaterIntakeHistory history) {
    try {
      final dateString = history.date.toIso8601String().split('T')[0];
      return WaterIntakeHistoryTableCompanion.insert(
        id: dateString,
        date: history.date,
        dailyGoal: history.dailyGoal,
        measureUnit: history.measureUnit,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting history to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  Future<WaterIntakeHistory> historyFromData(WaterIntakeHistoryTableData data) async {
    try {
      final entries = await _db.getEntriesByHistoryId(data.id);
      return WaterIntakeHistory(
        date: data.date,
        entries: await Future.wait(entries.map((e) => entryFromData(e))),
        dailyGoal: data.dailyGoal,
        measureUnit: data.measureUnit,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to history model');
      rethrow;
    }
  }

  /// Chuyển đổi từ model sang dữ liệu bảng
  WaterIntakeEntryTableCompanion entryToCompanion(String historyId, WaterIntakeEntry entry) {
    try {
      final drinkTypeIndex = DrinkTypes.all.indexWhere((type) => type.id == entry.drinkType.id);
      if (drinkTypeIndex == -1) {
        throw ArgumentError('Invalid drink type: ${entry.drinkType.id}');
      }

      return WaterIntakeEntryTableCompanion.insert(
        id: entry.id,
        historyId: historyId,
        timestamp: entry.timestamp,
        amount: entry.amount,
        drinkTypeId: drinkTypeIndex,
        note: entry.note != null ? Value(entry.note) : const Value.absent(),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting entry to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  Future<WaterIntakeEntry> entryFromData(WaterIntakeEntryTableData data) async {
    try {
      if (data.drinkTypeId < 0 || data.drinkTypeId >= DrinkTypes.all.length) {
        throw RangeError('Invalid drink type index: ${data.drinkTypeId}');
      }

      return WaterIntakeEntry(
        id: data.id,
        timestamp: data.timestamp,
        amount: data.amount,
        drinkType: DrinkTypes.all[data.drinkTypeId],
        note: data.note,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to entry model');
      rethrow;
    }
  }

  /// Lấy lịch sử uống nước theo ngày
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date) async {
    try {
      final data = await _db.getWaterIntakeHistoryByDate(date);
      if (data == null) return null;
      return historyFromData(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history');
      rethrow;
    }
  }

  /// Lưu lịch sử uống nước
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history) async {
    try {
      final dateString = history.date.toIso8601String().split('T')[0];

      // Lưu thông tin lịch sử
      await _db.insertOrUpdateWaterIntakeHistory(historyToCompanion(history));

      // Xóa các entries cũ (nếu có) để tránh trùng lặp
      await _db.transaction(() async {
        final existingEntries = await _db.getEntriesByHistoryId(dateString);
        for (final entry in existingEntries) {
          await _db.deleteWaterIntakeEntry(entry.id);
        }

        // Thêm các entries mới
        for (final entry in history.entries) {
          await _db.insertWaterIntakeEntry(entryToCompanion(dateString, entry));
        }
      });
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving water intake history');
      rethrow;
    }
  }

  /// Thêm một lần uống nước mới
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];

      // Kiểm tra xem đã có lịch sử cho ngày này chưa
      var historyData = await _db.getWaterIntakeHistoryByDate(date);

      // Nếu chưa có, tạo mới với mục tiêu mặc định
      if (historyData == null) {
        final defaultHistory = WaterIntakeHistory(
          date: date,
          entries: [],
          dailyGoal: 2500, // Mục tiêu mặc định
          measureUnit: MeasureUnit.metric,
        );
        await _db.insertOrUpdateWaterIntakeHistory(historyToCompanion(defaultHistory));
      }

      // Thêm entry mới
      await _db.insertWaterIntakeEntry(entryToCompanion(dateString, entry));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error adding water intake entry');
      rethrow;
    }
  }

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) async {
    try {
      await _db.deleteWaterIntakeEntry(entryId);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting water intake entry');
      rethrow;
    }
  }

  /// Lấy tất cả lịch sử uống nước
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final historyData = await _db.getAllWaterIntakeHistory(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
      return Future.wait(historyData.map((data) => historyFromData(data)));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting all water intake history');
      rethrow;
    }
  }

  /// Xóa tất cả lịch sử uống nước
  Future<void> clearAllWaterIntakeHistory() async {
    try {
      await _db.clearAllWaterIntakeHistory();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing all water intake history');
      rethrow;
    }
  }

  /// Xóa lịch sử uống nước cũ hơn một ngày cụ thể
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date) async {
    try {
      await _db.deleteWaterIntakeHistoryOlderThan(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting old water intake history');
      rethrow;
    }
  }
}
