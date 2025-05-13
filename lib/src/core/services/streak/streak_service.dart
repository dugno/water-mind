import 'package:water_mind/src/core/database/daos/user_streak_dao.dart';
import 'package:water_mind/src/core/models/user_streak_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Interface cho streak service
abstract class StreakService {
  /// Lấy thông tin streak của người dùng
  Future<UserStreakModel?> getUserStreak();

  /// Cập nhật streak khi người dùng uống nước
  Future<void> updateUserStreak(DateTime activityDate);

  /// Kiểm tra xem người dùng có streak trong ngày hôm nay không
  Future<bool> hasStreakToday();
}

/// Triển khai streak service
class StreakServiceImpl implements StreakService {
  final UserStreakDao _dao;

  /// Constructor
  StreakServiceImpl(this._dao);

  @override
  Future<UserStreakModel?> getUserStreak() async {
    try {
      return await _dao.getUserStreak();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user streak');
      rethrow;
    }
  }

  @override
  Future<void> updateUserStreak(DateTime activityDate) async {
    try {
      await _dao.updateUserStreak(activityDate);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating user streak');
      rethrow;
    }
  }

  @override
  Future<bool> hasStreakToday() async {
    try {
      final streak = await _dao.getUserStreak();
      if (streak == null) {
        return false;
      }

      // Chuẩn hóa ngày để so sánh (chỉ lấy ngày, tháng, năm)
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final normalizedLastActiveDate = DateTime(
        streak.lastActiveDate.year,
        streak.lastActiveDate.month,
        streak.lastActiveDate.day,
      );

      // Kiểm tra xem ngày cuối cùng hoạt động có phải là hôm nay không
      return normalizedToday.isAtSameMomentAs(normalizedLastActiveDate);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error checking if user has streak today');
      rethrow;
    }
  }
}
