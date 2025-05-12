import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/models/user_preferences_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// DAO cho tùy chọn người dùng
class UserPreferencesDao {
  final AppDatabase _db;

  /// Constructor
  UserPreferencesDao(this._db);

  /// Lấy tùy chọn người dùng
  Future<UserPreferencesModel?> getUserPreferences() async {
    try {
      final data = await _db.getUserPreferences();
      if (data == null) {
        return null;
      }
      return dataToModel(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user preferences');
      rethrow;
    }
  }

  /// Lưu tùy chọn người dùng
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      await _db.saveUserPreferences(modelToCompanion(preferences));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user preferences');
      rethrow;
    }
  }

  /// Cập nhật thông tin uống nước gần nhất
  Future<void> updateLastDrinkInfo(String drinkTypeId, double amount) async {
    try {
      await _db.updateLastDrinkInfo(drinkTypeId, amount);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating last drink info');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  UserPreferencesModel dataToModel(dynamic data) {
    try {
      return UserPreferencesModel(
        lastDrinkTypeId: data.lastDrinkTypeId,
        lastDrinkAmount: data.lastDrinkAmount,
        measureUnit: data.measureUnit,
        lastUpdated: data.lastUpdated,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to user preferences model');
      rethrow;
    }
  }

  /// Chuyển đổi từ model sang dữ liệu bảng
  dynamic modelToCompanion(UserPreferencesModel model) {
    try {
      return UserPreferencesTableCompanion(
        id: const Value('user_preferences'),
        lastDrinkTypeId: Value(model.lastDrinkTypeId),
        lastDrinkAmount: Value(model.lastDrinkAmount),
        measureUnit: Value(model.measureUnit),
        lastUpdated: Value(model.lastUpdated ?? DateTime.now()),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting user preferences model to companion');
      rethrow;
    }
  }
}
