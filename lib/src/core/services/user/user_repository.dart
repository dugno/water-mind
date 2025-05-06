import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Interface for user repository
abstract class UserRepository {
  /// Get the user data
  Future<UserOnboardingModel?> getUserData();

  /// Save the user data
  Future<void> saveUserData(UserOnboardingModel userData);
}

/// Implementation of user repository using SharedPreferences
class UserRepositoryImpl implements UserRepository {
  /// Key for storing user data
  static const String _userDataKey = 'user_data';

  @override
  Future<UserOnboardingModel?> getUserData() async {
    try {
      final jsonData = KVStoreService.sharedPreferences.getString(_userDataKey);
      if (jsonData == null) {
        return null;
      }

      final data = json.decode(jsonData) as Map<String, dynamic>;
      
      // Parse TimeOfDay objects
      TimeOfDay? wakeUpTime;
      if (data['wakeUpTime'] != null) {
        final timeParts = data['wakeUpTime'].split(':');
        wakeUpTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }

      TimeOfDay? bedTime;
      if (data['bedTime'] != null) {
        final timeParts = data['bedTime'].split(':');
        bedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }

      // Parse enums
      Gender? gender;
      if (data['gender'] != null) {
        gender = Gender.values.firstWhere(
          (e) => e.name == data['gender'],
          orElse: () => Gender.other,
        );
      }

      ActivityLevel? activityLevel;
      if (data['activityLevel'] != null) {
        activityLevel = ActivityLevel.values.firstWhere(
          (e) => e.name == data['activityLevel'],
          orElse: () => ActivityLevel.moderatelyActive,
        );
      }

      LivingEnvironment? livingEnvironment;
      if (data['livingEnvironment'] != null) {
        livingEnvironment = LivingEnvironment.values.firstWhere(
          (e) => e.name == data['livingEnvironment'],
          orElse: () => LivingEnvironment.moderate,
        );
      }

      MeasureUnit measureUnit = MeasureUnit.metric;
      if (data['measureUnit'] != null) {
        measureUnit = MeasureUnit.values.firstWhere(
          (e) => e.name == data['measureUnit'],
          orElse: () => MeasureUnit.metric,
        );
      }

      // Parse date
      DateTime? dateOfBirth;
      if (data['dateOfBirth'] != null) {
        dateOfBirth = DateTime.parse(data['dateOfBirth']);
      }

      return UserOnboardingModel(
        gender: gender,
        height: data['height'],
        weight: data['weight'],
        measureUnit: measureUnit,
        dateOfBirth: dateOfBirth,
        activityLevel: activityLevel,
        livingEnvironment: livingEnvironment,
        wakeUpTime: wakeUpTime,
        bedTime: bedTime,
      );
    } catch (e) {
      debugPrint('Error loading user data: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserData(UserOnboardingModel userData) async {
    try {
      // Convert to JSON-compatible format
      final Map<String, dynamic> jsonMap = {
        'gender': userData.gender?.name,
        'height': userData.height,
        'weight': userData.weight,
        'measureUnit': userData.measureUnit.name,
        'dateOfBirth': userData.dateOfBirth?.toIso8601String(),
        'activityLevel': userData.activityLevel?.name,
        'livingEnvironment': userData.livingEnvironment?.name,
        'wakeUpTime': userData.wakeUpTime != null
            ? '${userData.wakeUpTime!.hour}:${userData.wakeUpTime!.minute}'
            : null,
        'bedTime': userData.bedTime != null
            ? '${userData.bedTime!.hour}:${userData.bedTime!.minute}'
            : null,
      };

      // Save to storage
      await KVStoreService.sharedPreferences.setString(
        _userDataKey,
        json.encode(jsonMap),
      );
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }
}
