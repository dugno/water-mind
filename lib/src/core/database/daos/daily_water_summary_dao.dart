import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/models/daily_water_summary.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// DAO cho tổng lượng nước uống theo ngày
class DailyWaterSummaryDao {
  final AppDatabase _db;

  /// Constructor
  DailyWaterSummaryDao(this._db);

  /// Chuyển đổi từ model sang dữ liệu bảng
  DailyWaterSummaryTableCompanion modelToCompanion(DailyWaterSummary model) {
    try {
      final dateString = model.date.toIso8601String().split('T')[0];
      return DailyWaterSummaryTableCompanion.insert(
        id: dateString,
        date: model.date,
        userId: model.userId,
        totalAmount: model.totalAmount,
        totalEffectiveAmount: model.totalEffectiveAmount,
        dailyGoal: model.dailyGoal,
        measureUnit: model.measureUnit,
        goalMet: Value(model.goalMet),
        lastUpdated: model.lastUpdated ?? DateTime.now(),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting daily water summary model to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  DailyWaterSummary dataToModel(DailyWaterSummaryTableData data) {
    try {
      return DailyWaterSummary(
        date: data.date,
        userId: data.userId,
        totalAmount: data.totalAmount,
        totalEffectiveAmount: data.totalEffectiveAmount,
        dailyGoal: data.dailyGoal,
        measureUnit: data.measureUnit,
        goalMet: data.goalMet,
        lastUpdated: data.lastUpdated,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to daily water summary model');
      rethrow;
    }
  }

  /// Lấy tổng lượng nước uống theo ngày
  Future<DailyWaterSummary?> getDailyWaterSummary(DateTime date, {String userId = 'current_user'}) async {
    try {
      // Chuẩn hóa ngày để đảm bảo chỉ có ngày, tháng, năm (không có giờ, phút, giây)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateString = normalizedDate.toIso8601String().split('T')[0];
      AppLogger.info('DAO: Getting daily water summary for date: $dateString');

      final data = await _db.getDailyWaterSummaryByDate(normalizedDate, userId);
      if (data == null) {
        AppLogger.info('No daily water summary found for date: $dateString');
        return null;
      }

      return dataToModel(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting daily water summary');
      rethrow;
    }
  }

  /// Lưu tổng lượng nước uống theo ngày
  Future<void> saveDailyWaterSummary(DailyWaterSummary summary) async {
    try {
      final companion = modelToCompanion(summary);
      await _db.saveDailyWaterSummary(companion);
      AppLogger.info('Saved daily water summary for date: ${summary.date.toIso8601String().split('T')[0]}');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving daily water summary');
      rethrow;
    }
  }

  /// Lấy tất cả tổng lượng nước uống
  Future<List<DailyWaterSummary>> getAllDailyWaterSummaries({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
    String userId = 'current_user',
  }) async {
    try {
      final data = await _db.getAllDailyWaterSummaries(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
        userId: userId,
      );
      
      return data.map(dataToModel).toList();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting all daily water summaries');
      rethrow;
    }
  }

  /// Xóa tất cả tổng lượng nước uống
  Future<void> clearAllDailyWaterSummaries({String userId = 'current_user'}) async {
    try {
      await _db.clearAllDailyWaterSummaries(userId);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing all daily water summaries');
      rethrow;
    }
  }
}
