import 'package:flutter/material.dart';
import 'models/reminder_mode.dart';
import 'models/water_reminder_model.dart';

/// Interface for the reminder service
abstract class ReminderServiceInterface {
  /// Initialize the reminder service
  Future<void> initialize();
  
  /// Get the current reminder settings
  Future<WaterReminderModel> getReminderSettings();
  
  /// Save reminder settings
  Future<void> saveReminderSettings(WaterReminderModel settings);
  
  /// Schedule reminders based on the current settings
  Future<void> scheduleReminders();
  
  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders();
  
  /// Enable or disable reminders
  Future<void> setRemindersEnabled(bool enabled);
  
  /// Set the reminder mode
  Future<void> setReminderMode(ReminderMode mode);
  
  /// Set the wake up time
  Future<void> setWakeUpTime(TimeOfDay time);
  
  /// Set the bedtime
  Future<void> setBedTime(TimeOfDay time);
  
  /// Set the interval for interval mode
  Future<void> setIntervalMinutes(int minutes);
  
  /// Set custom reminder times for custom mode
  Future<void> setCustomTimes(List<TimeOfDay> times);
  
  /// Set whether to skip reminders if the goal is met
  Future<void> setSkipIfGoalMet(bool skip);
  
  /// Set whether to enable "Do not disturb" mode
  Future<void> setDoNotDisturbEnabled(bool enabled);
  
  /// Set the "Do not disturb" period
  Future<void> setDoNotDisturbPeriod(TimeOfDay start, TimeOfDay end);
}
