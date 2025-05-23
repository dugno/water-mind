import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/hydration/daily_water_summary_repository.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_change_notifier.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/streak/streak_provider.dart';

/// Interface cho water intake repository
abstract class WaterIntakeRepository {
  /// Lấy lịch sử uống nước theo ngày
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date);

  /// Lưu lịch sử uống nước
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history);

  /// Thêm một lần uống nước mới
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry);

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId);

  /// Lấy tất cả lịch sử uống nước
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Xóa tất cả lịch sử uống nước
  Future<void> clearAllWaterIntakeHistory();

  /// Xóa lịch sử uống nước cũ hơn một ngày cụ thể
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date);
}

class DriftWaterIntakeRepository implements WaterIntakeRepository {
  final WaterIntakeDao _dao;
  final Ref _ref;
  final DailyWaterSummaryRepository _dailyWaterSummaryRepository;

  DriftWaterIntakeRepository(this._dao, this._ref, this._dailyWaterSummaryRepository);

  @override
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      AppLogger.info('REPOSITORY: Getting water intake history for date: $dateString');
      final result = await _dao.getWaterIntakeHistory(date);
      AppLogger.info('REPOSITORY: History found: ${result != null}');
      if (result != null) {
        AppLogger.info('REPOSITORY: Entries count: ${result.entries.length}');
      }
      return result;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history');
      rethrow;
    }
  }

  @override
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history) async {
    try {
      await _dao.saveWaterIntakeHistory(history);

      // Cập nhật tổng lượng nước uống theo ngày
      await _dailyWaterSummaryRepository.updateFromWaterIntakeHistory(history);
      AppLogger.info('REPOSITORY: Updated daily water summary after saving history');

      // Thông báo rằng dữ liệu đã thay đổi
      _ref.read(waterIntakeChangeNotifierProvider.notifier).notifyDataChanged();
      AppLogger.info('REPOSITORY: Notified data change after saving history');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving water intake history');
      rethrow;
    }
  }

  @override
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      AppLogger.info('REPOSITORY: Adding water intake entry with ID: ${entry.id} for date: $dateString');
      final updatedHistory = await _dao.addWaterIntakeEntry(date, entry);
      AppLogger.info('REPOSITORY: Entry added successfully');

      // Cập nhật tổng lượng nước uống theo ngày
      await _dailyWaterSummaryRepository.updateFromWaterIntakeHistory(updatedHistory);
      AppLogger.info('REPOSITORY: Updated daily water summary after adding entry');

      // Cập nhật streak
      final streakService = _ref.read(streakServiceProvider);
      await streakService.updateUserStreak(date);
      AppLogger.info('REPOSITORY: Updated user streak');

      // Thông báo rằng dữ liệu đã thay đổi
      _ref.read(waterIntakeChangeNotifierProvider.notifier).notifyDataChanged();
      AppLogger.info('REPOSITORY: Notified data change');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error adding water intake entry');
      rethrow;
    }
  }

  @override
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      AppLogger.info('REPOSITORY: Deleting water intake entry with ID: $entryId for date: $dateString');
      await _dao.deleteWaterIntakeEntry(date, entryId);
      AppLogger.info('REPOSITORY: Entry deleted successfully');

      // Lấy lịch sử mới nhất sau khi xóa entry
      final updatedHistory = await getWaterIntakeHistory(date);
      if (updatedHistory != null) {
        // Cập nhật tổng lượng nước uống theo ngày
        await _dailyWaterSummaryRepository.updateFromWaterIntakeHistory(updatedHistory);
        AppLogger.info('REPOSITORY: Updated daily water summary after deleting entry');
      }

      // Thông báo rằng dữ liệu đã thay đổi
      _ref.read(waterIntakeChangeNotifierProvider.notifier).notifyDataChanged();
      AppLogger.info('REPOSITORY: Notified data change after deletion');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting water intake entry');
      rethrow;
    }
  }

  @override
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dao.getAllWaterIntakeHistory(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting all water intake history');
      rethrow;
    }
  }

  @override
  Future<void> clearAllWaterIntakeHistory() async {
    try {
      await _dao.clearAllWaterIntakeHistory();

      // Xóa tất cả tổng lượng nước uống theo ngày
      await _dailyWaterSummaryRepository.clearAllDailyWaterSummaries();
      AppLogger.info('REPOSITORY: Cleared all daily water summaries');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing all water intake history');
      rethrow;
    }
  }

  @override
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date) async {
    try {
      await _dao.deleteWaterIntakeHistoryOlderThan(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting old water intake history');
      rethrow;
    }
  }
}
