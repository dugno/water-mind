import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// DAO cho dữ liệu uống nước
class WaterIntakeDao {
  final AppDatabase _db;

  /// Constructor
  WaterIntakeDao(this._db);

  /// Chuyển đổi từ model sang dữ liệu bảng
  WaterIntakeHistoryTableCompanion historyToCompanion(WaterIntakeHistory history) {
    final dateString = history.date.toIso8601String().split('T')[0];
    return WaterIntakeHistoryTableCompanion.insert(
      id: dateString,
      date: dateString,
      dailyGoal: history.dailyGoal,
      measureUnit: history.measureUnit == MeasureUnit.metric ? 0 : 1,
    );
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  Future<WaterIntakeHistory> historyFromData(WaterIntakeHistoryTableData data) async {
    final entries = await _db.getEntriesByHistoryId(data.id);
    return WaterIntakeHistory(
      date: DateTime.parse(data.date),
      entries: await Future.wait(entries.map((e) => entryFromData(e))),
      dailyGoal: data.dailyGoal,
      measureUnit: data.measureUnit == 0 ? MeasureUnit.metric : MeasureUnit.imperial,
    );
  }

  /// Chuyển đổi từ model sang dữ liệu bảng
  WaterIntakeEntryTableCompanion entryToCompanion(String historyId, WaterIntakeEntry entry) {
    return WaterIntakeEntryTableCompanion.insert(
      id: entry.id,
      historyId: historyId,
      timestamp: entry.timestamp.toIso8601String(),
      amount: entry.amount,
      drinkTypeId: DrinkTypes.all.indexWhere((type) => type.id == entry.drinkType.id),
      note: Value(entry.note),
    );
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  Future<WaterIntakeEntry> entryFromData(WaterIntakeEntryTableData data) async {
    return WaterIntakeEntry(
      id: data.id,
      timestamp: DateTime.parse(data.timestamp),
      amount: data.amount,
      drinkType: DrinkTypes.all[data.drinkTypeId],
      note: data.note,
    );
  }

  /// Lấy lịch sử uống nước theo ngày
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date) async {
    final data = await _db.getWaterIntakeHistoryByDate(date);
    if (data == null) return null;
    return historyFromData(data);
  }

  /// Lưu lịch sử uống nước
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history) async {
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
  }

  /// Thêm một lần uống nước mới
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) async {
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
  }

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) async {
    await _db.deleteWaterIntakeEntry(entryId);
  }

  /// Lấy tất cả lịch sử uống nước
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory() async {
    final historyData = await _db.getAllWaterIntakeHistory();
    return Future.wait(historyData.map((data) => historyFromData(data)));
  }

  /// Xóa tất cả lịch sử uống nước
  Future<void> clearAllWaterIntakeHistory() async {
    await _db.clearAllWaterIntakeHistory();
  }
}
