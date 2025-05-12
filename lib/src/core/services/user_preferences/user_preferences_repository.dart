import 'package:water_mind/src/core/database/daos/user_preferences_dao.dart';
import 'package:water_mind/src/core/models/user_preferences_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Interface cho repository tùy chọn người dùng
abstract class UserPreferencesRepository {
  /// Lấy tùy chọn người dùng
  Future<UserPreferencesModel?> getUserPreferences();

  /// Lưu tùy chọn người dùng
  Future<void> saveUserPreferences(UserPreferencesModel preferences);

  /// Cập nhật thông tin uống nước gần nhất
  Future<void> updateLastDrinkInfo(String drinkTypeId, double amount);
}

/// Triển khai repository sử dụng Drift
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesDao _dao;

  /// Constructor
  UserPreferencesRepositoryImpl(this._dao);

  @override
  Future<UserPreferencesModel?> getUserPreferences() async {
    try {
      return await _dao.getUserPreferences();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user preferences');
      rethrow;
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      await _dao.saveUserPreferences(preferences);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user preferences');
      rethrow;
    }
  }

  @override
  Future<void> updateLastDrinkInfo(String drinkTypeId, double amount) async {
    try {
      await _dao.updateLastDrinkInfo(drinkTypeId, amount);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating last drink info');
      rethrow;
    }
  }
}
