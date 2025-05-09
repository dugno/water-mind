import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// DAO cho dữ liệu người dùng
class UserDataDao {
  final AppDatabase _db;

  /// Constructor
  UserDataDao(this._db);

  /// Chuyển đổi từ model sang dữ liệu bảng
  UserDataTableCompanion modelToCompanion(UserOnboardingModel model) {
    try {
      return UserDataTableCompanion.insert(
        id: 'current_user',
        gender: Value(model.gender),
        height: Value(model.height),
        weight: Value(model.weight),
        measureUnit: model.measureUnit,
        dateOfBirth: Value(model.dateOfBirth),
        activityLevel: Value(model.activityLevel),
        livingEnvironment: Value(model.livingEnvironment),
        wakeUpTime: Value(model.wakeUpTime),
        bedTime: Value(model.bedTime),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting user model to companion');
      rethrow;
    }
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  UserOnboardingModel dataToModel(UserDataTableData data) {
    try {
      return UserOnboardingModel(
        gender: data.gender,
        height: data.height,
        weight: data.weight,
        measureUnit: data.measureUnit,
        dateOfBirth: data.dateOfBirth,
        activityLevel: data.activityLevel,
        livingEnvironment: data.livingEnvironment,
        wakeUpTime: data.wakeUpTime,
        bedTime: data.bedTime,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to user model');
      rethrow;
    }
  }

  /// Lấy dữ liệu người dùng
  Future<UserOnboardingModel?> getUserData() async {
    try {
      final data = await _db.getUserData();
      if (data == null) {
        return null;
      }
      return dataToModel(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user data');
      rethrow;
    }
  }

  /// Lưu dữ liệu người dùng
  Future<void> saveUserData(UserOnboardingModel userData) async {
    try {
      await _db.saveUserData(modelToCompanion(userData));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user data');
      rethrow;
    }
  }

  /// Xóa dữ liệu người dùng
  Future<void> clearUserData() async {
    try {
      await _db.clearUserData();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing user data');
      rethrow;
    }
  }
}
