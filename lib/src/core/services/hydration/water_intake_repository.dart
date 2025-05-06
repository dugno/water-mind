import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';

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
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory();

  /// Xóa tất cả lịch sử uống nước
  Future<void> clearAllWaterIntakeHistory();
}

/// Triển khai repository sử dụng Drift
class DriftWaterIntakeRepository implements WaterIntakeRepository {
  final WaterIntakeDao _dao;

  /// Constructor
  DriftWaterIntakeRepository(this._dao);

  @override
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date) {
    return _dao.getWaterIntakeHistory(date);
  }

  @override
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history) {
    return _dao.saveWaterIntakeHistory(history);
  }

  @override
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) {
    return _dao.addWaterIntakeEntry(date, entry);
  }

  @override
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) {
    return _dao.deleteWaterIntakeEntry(date, entryId);
  }

  @override
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory() {
    return _dao.getAllWaterIntakeHistory();
  }

  @override
  Future<void> clearAllWaterIntakeHistory() {
    return _dao.clearAllWaterIntakeHistory();
  }
}
