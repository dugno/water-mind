import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/daos/user_data_dao.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Interface cho user repository
abstract class UserRepository {
  /// Lấy dữ liệu người dùng
  Future<UserOnboardingModel?> getUserData();

  /// Lưu dữ liệu người dùng
  Future<void> saveUserData(UserOnboardingModel userData);

  /// Xóa dữ liệu người dùng
  Future<void> clearUserData();
}

/// Triển khai repository sử dụng Drift
class UserRepositoryImpl implements UserRepository {
  final UserDataDao _dao;

  /// Constructor
  UserRepositoryImpl(this._dao);

  @override
  Future<UserOnboardingModel?> getUserData() async {
    try {
      return await _dao.getUserData();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user data');
      rethrow;
    }
  }

  @override
  Future<void> saveUserData(UserOnboardingModel userData) async {
    try {
      await _dao.saveUserData(userData);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user data');
      rethrow;
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await _dao.clearUserData();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing user data');
      rethrow;
    }
  }
}
