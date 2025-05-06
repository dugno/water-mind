import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/notifications/notification_factory.dart';
import 'package:water_mind/src/core/services/notifications/notification_manager.dart';
import 'models/reminder_mode.dart';
import 'models/water_reminder_model.dart';
import 'reminder_service_interface.dart';

/// Implementation of the reminder service for water intake reminders
class WaterReminderService implements ReminderServiceInterface {
  /// Key for storing reminder settings in KVStore
  static const String _reminderSettingsKey = 'water_reminder_settings';

  /// Notification channel key for water reminders
  static const String _notificationChannelKey = 'reminders_channel';

  /// The notification manager
  final NotificationManager _notificationManager;

  /// Current reminder settings
  WaterReminderModel? _settings;

  /// Constructor
  WaterReminderService({
    required NotificationManager notificationManager,
  }) : _notificationManager = notificationManager;

  @override
  Future<void> initialize() async {
    try {
      // Load settings from storage
      _settings = await getReminderSettings();

      // Check if notifications are allowed before scheduling
      final allowed = await _notificationManager.areNotificationsAllowed();

      // Schedule reminders if enabled and notifications are allowed
      if (_settings!.enabled) {
        if (allowed) {
          await scheduleReminders();
        } else {
          debugPrint('Reminders are enabled but notification permission is not granted');
          // We'll request permission when the user interacts with the app
        }
      }
    } catch (e) {
      debugPrint('Error initializing water reminder service: $e');
    }
  }

  @override
  Future<WaterReminderModel> getReminderSettings() async {
    if (_settings != null) {
      return _settings!;
    }

    // Try to load from storage
    final prefs = KVStoreService.sharedPreferences;
    final settingsJson = prefs.getString(_reminderSettingsKey);

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(settingsJson);

        // Convert TimeOfDay objects from strings
        if (jsonMap.containsKey('wakeUpTime')) {
          final timeString = jsonMap['wakeUpTime'] as String;
          jsonMap['wakeUpTime'] = WaterReminderModel.timeOfDayFromString(timeString);
        }

        if (jsonMap.containsKey('bedTime')) {
          final timeString = jsonMap['bedTime'] as String;
          jsonMap['bedTime'] = WaterReminderModel.timeOfDayFromString(timeString);
        }

        if (jsonMap.containsKey('doNotDisturbStart') && jsonMap['doNotDisturbStart'] != null) {
          final timeString = jsonMap['doNotDisturbStart'] as String;
          jsonMap['doNotDisturbStart'] = WaterReminderModel.timeOfDayFromString(timeString);
        }

        if (jsonMap.containsKey('doNotDisturbEnd') && jsonMap['doNotDisturbEnd'] != null) {
          final timeString = jsonMap['doNotDisturbEnd'] as String;
          jsonMap['doNotDisturbEnd'] = WaterReminderModel.timeOfDayFromString(timeString);
        }

        if (jsonMap.containsKey('customTimes') && jsonMap['customTimes'] != null) {
          final timeStrings = (jsonMap['customTimes'] as List).cast<String>();
          jsonMap['customTimes'] = timeStrings
              .map((t) => WaterReminderModel.timeOfDayFromString(t))
              .toList();
        }

        _settings = WaterReminderModel.fromJson(jsonMap);
        return _settings!;
      } catch (e) {
        debugPrint('Error loading reminder settings: $e');
      }
    }

    // Return default settings if none are saved
    _settings = WaterReminderModel.defaultSettings();
    return _settings!;
  }

  @override
  Future<void> saveReminderSettings(WaterReminderModel settings) async {
    _settings = settings;

    // Convert to JSON-compatible format
    final Map<String, dynamic> jsonMap = settings.toJson();

    // Convert TimeOfDay objects to strings
    jsonMap['wakeUpTime'] = WaterReminderModel.timeOfDayToString(settings.wakeUpTime);
    jsonMap['bedTime'] = WaterReminderModel.timeOfDayToString(settings.bedTime);

    if (settings.doNotDisturbStart != null) {
      jsonMap['doNotDisturbStart'] = WaterReminderModel.timeOfDayToString(settings.doNotDisturbStart!);
    }

    if (settings.doNotDisturbEnd != null) {
      jsonMap['doNotDisturbEnd'] = WaterReminderModel.timeOfDayToString(settings.doNotDisturbEnd!);
    }

    if (settings.customTimes.isNotEmpty) {
      jsonMap['customTimes'] = settings.customTimes
          .map((t) => WaterReminderModel.timeOfDayToString(t))
          .toList();
    }

    // Save to storage
    final prefs = KVStoreService.sharedPreferences;
    await prefs.setString(_reminderSettingsKey, json.encode(jsonMap));

    // Reschedule reminders if enabled
    if (settings.enabled) {
      await scheduleReminders();
    } else {
      await cancelAllReminders();
    }
  }

  @override
  Future<bool> scheduleReminders() async {
    try {
      // Check if notifications are allowed
      final allowed = await _notificationManager.areNotificationsAllowed();
      if (!allowed) {
        // Try to request permission
        final permissionGranted = await _notificationManager.requestPermission();
        if (!permissionGranted) {
          debugPrint('Cannot schedule reminders: notification permission denied');
          return false;
        }
      }

      // Cancel existing reminders first
      await cancelAllReminders();

      // Get current settings
      final settings = await getReminderSettings();

      if (!settings.enabled) {
        return true; // Successfully did nothing (as intended)
      }

      // Schedule based on the selected mode
      bool success = false;
      switch (settings.mode) {
        case ReminderMode.standard:
          success = await _scheduleStandardReminders(settings);
          break;
        case ReminderMode.interval:
          success = await _scheduleIntervalReminders(settings);
          break;
        case ReminderMode.custom:
          success = await _scheduleCustomReminders(settings);
          break;
      }

      return success;
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
      return false;
    }
  }

  /// Schedule reminders using the standard mode
  Future<bool> _scheduleStandardReminders(WaterReminderModel settings) async {
    try {
      // Calculate active hours
      final wakeHour = settings.wakeUpTime.hour;
      final wakeMinute = settings.wakeUpTime.minute;
      final bedHour = settings.bedTime.hour;
      final bedMinute = settings.bedTime.minute;

      // Convert to minutes since midnight for easier calculation
      final wakeTimeMinutes = wakeHour * 60 + wakeMinute;
      final bedTimeMinutes = bedHour * 60 + bedMinute;

      // Calculate active period in minutes
      int activePeriodMinutes = bedTimeMinutes - wakeTimeMinutes;
      if (activePeriodMinutes <= 0) {
        // Handle case where bedtime is on the next day
        activePeriodMinutes += 24 * 60;
      }

      // Schedule 6-8 reminders during active hours
      final reminderCount = activePeriodMinutes >= 720 ? 8 : 6;
      final interval = activePeriodMinutes / (reminderCount + 1);

      bool allSucceeded = true;
      for (int i = 1; i <= reminderCount; i++) {
        final reminderTimeMinutes = (wakeTimeMinutes + (interval * i).round()) % (24 * 60);
        final reminderHour = reminderTimeMinutes ~/ 60;
        final reminderMinute = reminderTimeMinutes % 60;

        final success = await _scheduleReminderAtTime(reminderHour, reminderMinute, i);
        if (!success) {
          allSucceeded = false;
        }
      }

      return allSucceeded;
    } catch (e) {
      debugPrint('Error scheduling standard reminders: $e');
      return false;
    }
  }

  /// Schedule reminders at regular intervals
  Future<bool> _scheduleIntervalReminders(WaterReminderModel settings) async {
    try {
      // Calculate active hours
      final wakeHour = settings.wakeUpTime.hour;
      final wakeMinute = settings.wakeUpTime.minute;
      final bedHour = settings.bedTime.hour;
      final bedMinute = settings.bedTime.minute;

      // Convert to minutes since midnight for easier calculation
      final wakeTimeMinutes = wakeHour * 60 + wakeMinute;
      final bedTimeMinutes = bedHour * 60 + bedMinute;

      // Calculate active period in minutes
      int activePeriodMinutes = bedTimeMinutes - wakeTimeMinutes;
      if (activePeriodMinutes <= 0) {
        // Handle case where bedtime is on the next day
        activePeriodMinutes += 24 * 60;
      }

      // Schedule reminders at the specified interval
      final interval = settings.intervalMinutes;
      final reminderCount = activePeriodMinutes ~/ interval;

      bool allSucceeded = true;
      for (int i = 0; i < reminderCount; i++) {
        final reminderTimeMinutes = (wakeTimeMinutes + (interval * (i + 1))) % (24 * 60);
        final reminderHour = reminderTimeMinutes ~/ 60;
        final reminderMinute = reminderTimeMinutes % 60;

        final success = await _scheduleReminderAtTime(reminderHour, reminderMinute, i + 1);
        if (!success) {
          allSucceeded = false;
        }
      }

      return allSucceeded;
    } catch (e) {
      debugPrint('Error scheduling interval reminders: $e');
      return false;
    }
  }

  /// Schedule custom reminders at specific times
  Future<bool> _scheduleCustomReminders(WaterReminderModel settings) async {
    try {
      if (settings.customTimes.isEmpty) {
        return true; // No reminders to schedule is considered success
      }

      bool allSucceeded = true;
      for (int i = 0; i < settings.customTimes.length; i++) {
        final time = settings.customTimes[i];
        final success = await _scheduleReminderAtTime(time.hour, time.minute, i + 1);
        if (!success) {
          allSucceeded = false;
        }
      }

      return allSucceeded;
    } catch (e) {
      debugPrint('Error scheduling custom reminders: $e');
      return false;
    }
  }

  /// Schedule a single reminder at a specific time
  Future<bool> _scheduleReminderAtTime(int hour, int minute, int id) async {
    try {
      // Check if notifications are allowed first
      final allowed = await _notificationManager.areNotificationsAllowed();
      if (!allowed) {
        // Try to request permission
        final permissionGranted = await _notificationManager.requestPermission();
        if (!permissionGranted) {
          debugPrint('Cannot schedule reminder: notification permission denied');
          return false;
        }
      }

      // Create a DateTime for today with the specified time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Create the notification
      final notification = NotificationFactory.createReminderNotification(
        channelKey: _notificationChannelKey,
        title: 'Time to hydrate!',
        body: 'Remember to drink water to stay hydrated.',
        id: 1000 + id, // Use a unique ID range for water reminders
      );

      // Schedule the notification
      final success = await _notificationManager.scheduleNotification(notification, scheduledDate);
      if (!success) {
        debugPrint('Failed to schedule reminder at $hour:$minute');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      return false;
    }
  }

  @override
  Future<void> cancelAllReminders() async {
    // Cancel all water reminder notifications (IDs 1000-1100)
    for (int i = 1000; i <= 1100; i++) {
      await _notificationManager.cancelNotification(i);
    }
  }

  @override
  Future<void> setRemindersEnabled(bool enabled) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(enabled: enabled));
  }

  @override
  Future<void> setReminderMode(ReminderMode mode) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(mode: mode));
  }

  @override
  Future<void> setWakeUpTime(TimeOfDay time) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(wakeUpTime: time));
  }

  @override
  Future<void> setBedTime(TimeOfDay time) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(bedTime: time));
  }

  @override
  Future<void> setIntervalMinutes(int minutes) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(intervalMinutes: minutes));
  }

  @override
  Future<void> setCustomTimes(List<TimeOfDay> times) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(customTimes: times));
  }

  @override
  Future<void> setSkipIfGoalMet(bool skip) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(skipIfGoalMet: skip));
  }

  @override
  Future<void> setDoNotDisturbEnabled(bool enabled) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(enableDoNotDisturb: enabled));
  }

  @override
  Future<void> setDoNotDisturbPeriod(TimeOfDay start, TimeOfDay end) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(
      doNotDisturbStart: start,
      doNotDisturbEnd: end,
    ));
  }
}
