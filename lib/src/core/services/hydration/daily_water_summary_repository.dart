import 'package:water_mind/src/core/database/daos/daily_water_summary_dao.dart';
import 'package:water_mind/src/core/models/daily_water_summary.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Interface cho daily water summary repository
abstract class DailyWaterSummaryRepository {
  /// Lấy tổng lượng nước uống theo ngày
  Future<DailyWaterSummary?> getDailyWaterSummary(DateTime date);

  /// Lưu tổng lượng nước uống theo ngày
  Future<void> saveDailyWaterSummary(DailyWaterSummary summary);

  /// Cập nhật tổng lượng nước uống từ lịch sử uống nước
  Future<DailyWaterSummary> updateFromWaterIntakeHistory(WaterIntakeHistory history);

  /// Lấy tất cả tổng lượng nước uống
  Future<List<DailyWaterSummary>> getAllDailyWaterSummaries({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Xóa tất cả tổng lượng nước uống
  Future<void> clearAllDailyWaterSummaries();
}

/// Triển khai repository sử dụng Drift
class DailyWaterSummaryRepositoryImpl implements DailyWaterSummaryRepository {
  final DailyWaterSummaryDao _dao;

  /// Constructor
  DailyWaterSummaryRepositoryImpl(this._dao);

  @override
  Future<DailyWaterSummary?> getDailyWaterSummary(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      AppLogger.info('REPOSITORY: Getting daily water summary for date: $dateString');
      return await _dao.getDailyWaterSummary(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting daily water summary');
      rethrow;
    }
  }

  @override
  Future<void> saveDailyWaterSummary(DailyWaterSummary summary) async {
    try {
      final dateString = summary.date.toIso8601String().split('T')[0];
      AppLogger.info('REPOSITORY: Saving daily water summary for date: $dateString');
      await _dao.saveDailyWaterSummary(summary);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving daily water summary');
      rethrow;
    }
  }

  @override
  Future<DailyWaterSummary> updateFromWaterIntakeHistory(WaterIntakeHistory history) async {
    try {
      final dateString = history.date.toIso8601String().split('T')[0];
      AppLogger.info('REPOSITORY: Updating daily water summary from history for date: $dateString');

      final summary = DailyWaterSummary(
        date: history.date,
        userId: 'current_user',
        totalAmount: history.totalAmount,
        totalEffectiveAmount: history.totalEffectiveAmount,
        dailyGoal: history.dailyGoal,
        measureUnit: history.measureUnit,
        goalMet: history.goalMet,
        lastUpdated: DateTime.now(),
      );

      // Lưu vào cơ sở dữ liệu
      await _dao.saveDailyWaterSummary(summary);
      return summary;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating daily water summary from history');
      rethrow;
    }
  }

  @override
  Future<List<DailyWaterSummary>> getAllDailyWaterSummaries({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info('REPOSITORY: Getting all daily water summaries');
      return await _dao.getAllDailyWaterSummaries(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting all daily water summaries');
      rethrow;
    }
  }

  @override
  Future<void> clearAllDailyWaterSummaries() async {
    try {
      AppLogger.info('REPOSITORY: Clearing all daily water summaries');
      await _dao.clearAllDailyWaterSummaries();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing all daily water summaries');
      rethrow;
    }
  }
}
