import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/notifications/notification_factory.dart';
import 'package:water_mind/src/core/services/notifications/notification_manager.dart';
import 'package:water_mind/src/core/services/reminders/reminder_repository.dart';
import 'models/reminder_mode.dart';
import 'models/water_reminder_model.dart';
import 'reminder_service_interface.dart';

/// Implementation of the reminder service for water intake reminders
class WaterReminderService implements ReminderServiceInterface {


  /// Notification channel key for water reminders
  static const String _notificationChannelKey = 'reminders_channel';

  /// The notification manager
  final NotificationManager _notificationManager;

  /// Current reminder settings
  WaterReminderModel? _settings;

  /// Repository for reminder settings
  final ReminderRepository _reminderRepository;

  /// Constructor
  WaterReminderService({
    required NotificationManager notificationManager,
    required ReminderRepository reminderRepository,
  }) : _notificationManager = notificationManager,
       _reminderRepository = reminderRepository;

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
      AppLogger.reportError(e, StackTrace.current, 'Error initializing water reminder service');
      debugPrint('Error initializing water reminder service: $e');
    }
  }


  @override
  Future<WaterReminderModel> getReminderSettings() async {
    if (_settings != null) {
      return _settings!;
    }

    try {
      // Try to load from repository
      final settings = await _reminderRepository.getReminderSettings();

      if (settings != null) {
        _settings = settings;
        return _settings!;
      }

      // Return default settings if none are saved
      _settings = WaterReminderModel.defaultSettings();

      // Save default settings to repository
      await _reminderRepository.saveReminderSettings(_settings!);

      return _settings!;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error loading reminder settings');
      debugPrint('Error loading reminder settings: $e');

      // Return default settings in case of error
      _settings = WaterReminderModel.defaultSettings();
      return _settings!;
    }
  }

  @override
  Future<void> saveReminderSettings(WaterReminderModel settings) async {
    try {
      _settings = settings;

      // Save to repository
      await _reminderRepository.saveReminderSettings(settings);

      // Reschedule reminders if enabled
      if (settings.enabled) {
        await scheduleReminders();
      } else {
        await cancelAllReminders();
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving reminder settings');
      debugPrint('Error saving reminder settings: $e');
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
