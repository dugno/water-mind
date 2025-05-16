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

      // Log thông tin chi tiết
      AppLogger.info('Creating companion for history:');
      AppLogger.info('- dateString: $dateString');
      AppLogger.info('- date: ${history.date}');
      AppLogger.info('- dailyGoal: ${history.dailyGoal}');
      AppLogger.info('- measureUnit: ${history.measureUnit}');

      // Tạo companion với Value thay vì giá trị trực tiếp
      final companion = WaterIntakeHistoryTableCompanion(
        id: Value(dateString),
        date: Value(history.date),
        dailyGoal: Value(history.dailyGoal),
        measureUnit: Value(history.measureUnit),
      );

      AppLogger.info('Created companion: id=${companion.id.value}, date=${companion.date.value}');
      return companion;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting history to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  Future<WaterIntakeHistory> historyFromData(WaterIntakeHistoryTableData data) async {
    try {
      AppLogger.info('Converting history data to model for ID: ${data.id}');

      // Lấy danh sách entries
      final entriesData = await _db.getEntriesByHistoryId(data.id);
      AppLogger.info('Found ${entriesData.length} entries for history ID: ${data.id}');

      // Chuyển đổi từng entry
      final entries = await Future.wait(entriesData.map((e) async {
        try {
          final entry = await entryFromData(e);
          AppLogger.info('Converted entry: ${entry.id}, amount: ${entry.amount} ml, type: ${entry.drinkType.id}');
          return entry;
        } catch (e) {
          AppLogger.reportError(e, StackTrace.current, 'Error converting entry data');
          rethrow;
        }
      }));

      // Tạo history model
      final history = WaterIntakeHistory(
        date: data.date,
        entries: entries,
        dailyGoal: data.dailyGoal,
        measureUnit: data.measureUnit,
      );

      AppLogger.info('History converted with ${history.entries.length} entries, total: ${history.totalAmount} ml, goal: ${history.dailyGoal} ml');
      return history;
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
      // Chuẩn hóa ngày để đảm bảo chỉ có ngày, tháng, năm (không có giờ, phút, giây)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateString = normalizedDate.toIso8601String().split('T')[0];
      AppLogger.info('DAO: Getting water intake history for date: $dateString');

      final data = await _db.getWaterIntakeHistoryByDate(normalizedDate);
      if (data == null) {
        AppLogger.info('No history found for date: $dateString');
        return null;
      }

      // Lấy danh sách entries
      final entries = await _db.getEntriesByHistoryId(data.id);
      AppLogger.info('Found ${entries.length} entries for date: $dateString');

      // Chuyển đổi dữ liệu
      final history = await historyFromData(data);
      AppLogger.info('History converted with ${history.entries.length} entries, total amount: ${history.totalAmount} ml');

      return history;
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
  Future<WaterIntakeHistory> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) async {
    try {
      // Chuẩn hóa ngày để đảm bảo chỉ có ngày, tháng, năm (không có giờ, phút, giây)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateString = normalizedDate.toIso8601String().split('T')[0];
      AppLogger.info('DAO: Adding water intake entry for date: $dateString, entry timestamp: ${entry.timestamp}');

      // Kiểm tra xem đã có lịch sử cho ngày này chưa
      var historyData = await _db.getWaterIntakeHistoryByDate(normalizedDate);

      // Nếu chưa có, tạo mới với mục tiêu mặc định
      if (historyData == null) {
        AppLogger.info('No history found for date: $dateString, creating new one');
        final defaultHistory = WaterIntakeHistory(
          date: normalizedDate,
          entries: [],
          dailyGoal: 2500, // Mục tiêu mặc định
          measureUnit: MeasureUnit.metric,
        );

        // Tạo companion và thêm vào database
        final historyCompanion = historyToCompanion(defaultHistory);
        await _db.insertOrUpdateWaterIntakeHistory(historyCompanion);
        AppLogger.info('Created new history record');

        // Lấy lại dữ liệu sau khi tạo mới
        historyData = await _db.getWaterIntakeHistoryByDate(normalizedDate);
        if (historyData == null) {
          throw Exception('Failed to create history record for date: $dateString');
        }

        AppLogger.info('Confirmed new history record for date: $dateString, id: ${historyData.id}');
      } else {
        AppLogger.info('Found existing history for date: $dateString, id: ${historyData.id}');
      }

      // Thêm entry mới
      final entryCompanion = entryToCompanion(dateString, entry);
      await _db.insertWaterIntakeEntry(entryCompanion);
      AppLogger.info('Added water intake entry');

      // Log thông tin để debug
      AppLogger.info('Added water intake entry: ${entry.amount} ml, type: ${entry.drinkType.id} for date: $dateString');

      // Kiểm tra xem entry đã được thêm thành công chưa
      final entries = await _db.getEntriesByHistoryId(dateString);
      AppLogger.info('Current entries count for $dateString: ${entries.length}');

      // Lấy lịch sử mới nhất sau khi thêm entry
      final updatedHistory = await getWaterIntakeHistory(normalizedDate);
      if (updatedHistory == null) {
        throw Exception('Failed to get updated history after adding entry');
      }

      AppLogger.info('Updated history has ${updatedHistory.entries.length} entries, total: ${updatedHistory.totalAmount} ml');
      return updatedHistory;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error adding water intake entry');
      rethrow;
    }
  }

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) async {
    try {
      // Chuẩn hóa ngày để đảm bảo chỉ có ngày, tháng, năm (không có giờ, phút, giây)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateString = normalizedDate.toIso8601String().split('T')[0];
      AppLogger.info('DAO: Deleting water intake entry with ID: $entryId for date: $dateString');

      // Xóa entry
      await _db.deleteWaterIntakeEntry(entryId);
      AppLogger.info('DAO: Entry deleted successfully');
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

  /// Phương thức này được giữ lại để tương thích với mã hiện có
  /// nhưng không còn thực hiện xóa dữ liệu
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date) async {
    // Không làm gì cả, giữ lại tất cả dữ liệu
    AppLogger.info('Database cleanup disabled. All water intake history will be kept for the entire app lifecycle.');
  }
}
