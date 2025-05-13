import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/models/user_streak_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// DAO cho thông tin streak của người dùng
class UserStreakDao {
  final AppDatabase _db;

  /// Constructor
  UserStreakDao(this._db);

  /// Chuyển đổi từ model sang dữ liệu bảng
  UserStreakTableCompanion modelToCompanion(UserStreakModel model) {
    try {
      return UserStreakTableCompanion(
        id: const Value('user_streak'),
        currentStreak: Value(model.currentStreak),
        longestStreak: Value(model.longestStreak),
        lastActiveDate: Value(model.lastActiveDate),
        lastUpdated: Value(DateTime.now()),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting user streak model to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  UserStreakModel dataToModel(UserStreakTableData data) {
    try {
      return UserStreakModel(
        currentStreak: data.currentStreak,
        longestStreak: data.longestStreak,
        lastActiveDate: data.lastActiveDate,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting user streak data to model');
      rethrow;
    }
  }

  /// Lấy thông tin streak của người dùng
  Future<UserStreakModel?> getUserStreak() async {
    try {
      final data = await _db.getUserStreak();
      if (data == null) {
        return null;
      }
      return dataToModel(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user streak');
      rethrow;
    }
  }

  /// Lưu thông tin streak của người dùng
  Future<void> saveUserStreak(UserStreakModel streak) async {
    try {
      await _db.saveUserStreak(modelToCompanion(streak));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user streak');
      rethrow;
    }
  }

  /// Cập nhật streak khi người dùng uống nước
  Future<void> updateUserStreak(DateTime activityDate) async {
    try {
      await _db.updateUserStreak(activityDate);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating user streak');
      rethrow;
    }
  }
}
