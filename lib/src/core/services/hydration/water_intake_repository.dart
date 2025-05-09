import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

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

/// Triển khai repository sử dụng Drift
class DriftWaterIntakeRepository implements WaterIntakeRepository {
  final WaterIntakeDao _dao;

  /// Constructor
  DriftWaterIntakeRepository(this._dao);

  @override
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date) async {
    try {
      return await _dao.getWaterIntakeHistory(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history');
      rethrow;
    }
  }

  @override
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history) async {
    try {
      await _dao.saveWaterIntakeHistory(history);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving water intake history');
      rethrow;
    }
  }

  @override
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) async {
    try {
      await _dao.addWaterIntakeEntry(date, entry);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error adding water intake entry');
      rethrow;
    }
  }

  @override
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) async {
    try {
      await _dao.deleteWaterIntakeEntry(date, entryId);
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
