import 'dart:math';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/notifications/notification_factory.dart';
import 'package:water_mind/src/core/services/notifications/notification_manager.dart';
import 'package:water_mind/src/core/services/reminders/reminder_repository.dart';
import 'package:water_mind/src/core/services/user/user_repository.dart';
import 'package:water_mind/src/core/services/weather/daily_weather_service.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'models/reminder_mode.dart';
import 'models/water_reminder_model.dart';
import 'reminder_service_interface.dart';

/// Class to hold notification content
class _NotificationContent {
  /// Title of the notification
  final String title;

  /// Body of the notification
  final String body;

  /// Progress percentage (0.0 to 1.0)
  final double? progress;

  /// Constructor
  _NotificationContent({
    required this.title,
    required this.body,
    this.progress,
  });
}

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

  /// Repository for user data
  final UserRepository _userRepository;

  /// Repository for water intake data
  final WaterIntakeRepository _waterIntakeRepository;

  /// Service for weather data
  final DailyWeatherService _weatherService;

  /// Constructor
  WaterReminderService({
    required NotificationManager notificationManager,
    required ReminderRepository reminderRepository,
    required UserRepository userRepository,
    required WaterIntakeRepository waterIntakeRepository,
    required DailyWeatherService weatherService,
  }) : _notificationManager = notificationManager,
       _reminderRepository = reminderRepository,
       _userRepository = userRepository,
       _waterIntakeRepository = waterIntakeRepository,
       _weatherService = weatherService;

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
      debugPrint('Saving reminder settings: mode=${settings.mode.name}, enabled=${settings.enabled}');

      // Check if settings have actually changed
      final oldSettings = _settings;
      final modeChanged = oldSettings != null && oldSettings.mode != settings.mode;
      final enabledChanged = oldSettings != null && oldSettings.enabled != settings.enabled;

      _settings = settings;

      // Save to repository
      await _reminderRepository.saveReminderSettings(settings);
      debugPrint('Reminder settings saved to repository');

      // Reschedule reminders if enabled
      if (settings.enabled) {
        if (modeChanged) {
          debugPrint('Reminder mode changed, rescheduling reminders...');
        } else if (enabledChanged) {
          debugPrint('Reminders were disabled and are now enabled, scheduling reminders...');
        } else {
          debugPrint('Reminder settings changed, rescheduling reminders...');
        }
        await scheduleReminders();
      } else {
        if (enabledChanged) {
          debugPrint('Reminders were enabled and are now disabled, cancelling all reminders...');
        } else {
          debugPrint('Reminders are disabled, cancelling any existing reminders...');
        }
        await cancelAllReminders();
      }

      debugPrint('Reminder settings update completed successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving reminder settings');
      debugPrint('Error saving reminder settings: $e');
    }
  }



  @override
  Future<bool> scheduleReminders() async {
    try {
      debugPrint('Starting to schedule water reminders...');

      // Check if notifications are allowed
      final allowed = await _notificationManager.areNotificationsAllowed();
      if (!allowed) {
        // Try to request permission
        debugPrint('Notification permission not granted, requesting permission...');
        final permissionGranted = await _notificationManager.requestPermission();
        if (!permissionGranted) {
          debugPrint('Cannot schedule reminders: notification permission denied by user');
          return false;
        }
        debugPrint('Notification permission granted by user');
      }

      // Cancel existing reminders first
      debugPrint('Cancelling any existing reminders before scheduling new ones...');
      await cancelAllReminders();

      // Get current settings
      final settings = await getReminderSettings();
      debugPrint('Retrieved reminder settings: mode=${settings.mode.name}, enabled=${settings.enabled}');

      if (!settings.enabled) {
        debugPrint('Reminders are disabled, not scheduling any reminders');
        return true; // Successfully did nothing (as intended)
      }

      // Schedule based on the selected mode
      bool success = false;
      debugPrint('Scheduling reminders using ${settings.mode.name} mode');

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

      // Schedule the special morning weather notification at 6 AM
      debugPrint('Scheduling additional morning weather notification...');
      await _scheduleMorningWeatherNotification();

      debugPrint('Reminder scheduling completed with ${success ? 'SUCCESS' : 'FAILURE'}');
      return success;
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error scheduling reminders');
      return false;
    }
  }

  /// Schedule reminders using the standard mode
  Future<bool> _scheduleStandardReminders(WaterReminderModel settings) async {
    try {
      debugPrint('Scheduling standard mode reminders...');

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

      debugPrint('Standard mode: Scheduling $reminderCount reminders at intervals of ~${interval.round()} minutes');
      debugPrint('Wake time: ${wakeHour.toString().padLeft(2, '0')}:${wakeMinute.toString().padLeft(2, '0')}, Bed time: ${bedHour.toString().padLeft(2, '0')}:${bedMinute.toString().padLeft(2, '0')}');

      bool allSucceeded = true;
      for (int i = 1; i <= reminderCount; i++) {
        final reminderTimeMinutes = (wakeTimeMinutes + (interval * i).round()) % (24 * 60);
        final reminderHour = reminderTimeMinutes ~/ 60;
        final reminderMinute = reminderTimeMinutes % 60;

        // Use ID range 1000-1020 for standard mode
        final notificationId = 1000 + i;

        debugPrint('Scheduling standard reminder #$i at ${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')} with ID $notificationId');

        final success = await _scheduleReminderAtTime(
          reminderHour,
          reminderMinute,
          notificationId
        );

        if (!success) {
          debugPrint('Failed to schedule standard reminder #$i');
          allSucceeded = false;
        }
      }

      debugPrint('Standard mode reminders scheduled: ${allSucceeded ? 'SUCCESS' : 'PARTIAL FAILURE'}');
      return allSucceeded;
    } catch (e) {
      debugPrint('Error scheduling standard reminders: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error scheduling standard reminders');
      return false;
    }
  }

  /// Schedule reminders at regular intervals
  Future<bool> _scheduleIntervalReminders(WaterReminderModel settings) async {
    try {
      debugPrint('Scheduling interval mode reminders...');

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

      debugPrint('Interval mode: Scheduling $reminderCount reminders at intervals of $interval minutes');
      debugPrint('Wake time: ${wakeHour.toString().padLeft(2, '0')}:${wakeMinute.toString().padLeft(2, '0')}, Bed time: ${bedHour.toString().padLeft(2, '0')}:${bedMinute.toString().padLeft(2, '0')}');

      bool allSucceeded = true;
      for (int i = 0; i < reminderCount; i++) {
        final reminderTimeMinutes = (wakeTimeMinutes + (interval * (i + 1))) % (24 * 60);
        final reminderHour = reminderTimeMinutes ~/ 60;
        final reminderMinute = reminderTimeMinutes % 60;

        // Use ID range 1030-1060 for interval mode
        final notificationId = 1030 + i;

        debugPrint('Scheduling interval reminder #${i+1} at ${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')} with ID $notificationId');

        final success = await _scheduleReminderAtTime(reminderHour, reminderMinute, notificationId);
        if (!success) {
          debugPrint('Failed to schedule interval reminder #${i+1}');
          allSucceeded = false;
        }
      }

      debugPrint('Interval mode reminders scheduled: ${allSucceeded ? 'SUCCESS' : 'PARTIAL FAILURE'}');
      return allSucceeded;
    } catch (e) {
      debugPrint('Error scheduling interval reminders: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error scheduling interval reminders');
      return false;
    }
  }

  /// Schedule custom reminders at specific times
  Future<bool> _scheduleCustomReminders(WaterReminderModel settings) async {
    try {
      debugPrint('Scheduling custom mode reminders...');

      if (settings.customTimes.isEmpty) {
        debugPrint('Custom mode: No custom times defined, nothing to schedule');
        return true; 
      }

      debugPrint('Custom mode: Scheduling ${settings.customTimes.length} reminders at user-defined times');

      bool allSucceeded = true;
      for (int i = 0; i < settings.customTimes.length; i++) {
        final time = settings.customTimes[i];

        // Use ID range 1070-1090 for custom mode
        final notificationId = 1070 + i;

        debugPrint('Scheduling custom reminder #${i+1} at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} with ID $notificationId');

        final success = await _scheduleReminderAtTime(time.hour, time.minute, notificationId);
        if (!success) {
          debugPrint('Failed to schedule custom reminder #${i+1}');
          allSucceeded = false;
        }
      }

      debugPrint('Custom mode reminders scheduled: ${allSucceeded ? 'SUCCESS' : 'PARTIAL FAILURE'}');
      return allSucceeded;
    } catch (e) {
      debugPrint('Error scheduling custom reminders: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error scheduling custom reminders');
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

      // Get user data and water intake history for personalization
      final userData = await _getUserData();
      final waterIntakeHistory = await _getWaterIntakeHistory();
      String weatherType;
      try {
        weatherType = await _getCurrentWeatherType();
        debugPrint('Using actual weather data for reminder: $weatherType');
      } catch (e) {
        weatherType = _getRandomWeatherType();
        debugPrint('Using fallback weather data for reminder: $weatherType');
      }

      final notificationContent = _generateNotificationContent(
        hour: hour,
        minute: minute,
        userData: userData,
        waterIntakeHistory: waterIntakeHistory,
        weatherType: weatherType
      );

      // Create the notification
      final notification = NotificationFactory.createReminderNotification(
        channelKey: _notificationChannelKey,
        title: notificationContent.title,
        body: notificationContent.body,
        id: id, // Use the provided ID directly
        payload: {
          'type': 'reminder',
          'time': '$hour:$minute',
          'progress': notificationContent.progress?.toString() ?? '0',
        },
      );

      // Schedule the notification
      final success = await _notificationManager.scheduleNotification(notification, scheduledDate);
      if (!success) {
        debugPrint('Failed to schedule reminder at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} with ID $id');
        return false;
      }

      debugPrint('Successfully scheduled reminder at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} with ID $id');
      return true;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error scheduling reminder');
      return false;
    }
  }

  /// Get user data for personalization
  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      // Lấy dữ liệu người dùng thực từ repository
      final userData = await _userRepository.getUserData();

      if (userData == null) {
        debugPrint('No user data found, using default values');
        return {
          'name': 'User',
          'dailyGoal': 0, // ml
          'language': 'en',
        };
      }

      // Chuyển đổi từ UserOnboardingModel sang Map
      return {
        'name': 'User', // Không có trường name trong UserOnboardingModel
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
        'language': 'vi', // Mặc định là tiếng Việt, có thể lấy từ UserPreferences nếu cần
      };
    } catch (e) {
      debugPrint('Error getting user data: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error getting user data for reminder');
      return null;
    }
  }

  /// Get water intake history for personalization
  Future<Map<String, dynamic>?> _getWaterIntakeHistory() async {
    try {
      // Lấy ngày hiện tại
      final now = DateTime.now();

      // Lấy lịch sử uống nước cho ngày hiện tại
      final history = await _waterIntakeRepository.getWaterIntakeHistory(now);

      if (history == null) {
        debugPrint('No water intake history found for today, using default values');
        return {
          'date': now,
          'totalAmount': 0.0, // ml
          'dailyGoal': 2500.0, // ml
          'progress': 0.0, // 0%
          'remainingAmount': 2500.0, // ml
        };
      }

      // Tính toán các giá trị
      final totalAmount = history.totalAmount;
      final dailyGoal = history.dailyGoal;
      final progress = history.progressPercentage;
      final remainingAmount = history.remainingAmount > 0 ? history.remainingAmount : 0.0;

      debugPrint('Water intake history for today: total=$totalAmount, goal=$dailyGoal, progress=$progress');

      return {
        'date': now,
        'totalAmount': totalAmount,
        'dailyGoal': dailyGoal,
        'progress': progress,
        'remainingAmount': remainingAmount,
        'goalMet': history.goalMet,
        'measureUnit': history.measureUnit.name,
      };
    } catch (e) {
      debugPrint('Error getting water intake history: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history for reminder');
      return null;
    }
  }

  /// Generate personalized notification content
  _NotificationContent _generateNotificationContent({
    required int hour,
    required int minute,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? waterIntakeHistory,
    String? weatherType,
  }) {
    // Default values if data is not available
    final double progress = waterIntakeHistory?['progress'] ?? 0.0;
    final double remainingAmount = waterIntakeHistory?['remainingAmount'] ?? 2500.0;
    final String language = userData?['language'] ?? 'en';

    // Get time of day to personalize message
    final timeOfDay = _getTimeOfDay(hour);

    // Use provided weather type or fallback to random
    final weatherConditionType = weatherType ?? _getRandomWeatherType();

    // Get localized messages
    final messages = _getLocalizedMessages(language);

    // Get title based on time of day
    final titles = messages['titles'];
    final title = titles.containsKey(timeOfDay) ? titles[timeOfDay] : titles['default'];

    // Get body message
    final body = _getBodyMessage(language, progress, remainingAmount, timeOfDay, weatherConditionType);

    return _NotificationContent(
      title: title,
      body: body,
      progress: progress,
    );
  }

  /// Get time of day category based on hour
  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  /// Get localized notification messages based on language code
  Map<String, dynamic> _getLocalizedMessages(String languageCode) {
    // Define messages for Vietnamese
    if (languageCode == 'vi') {
      return {
        'titles': {
          'morning': 'Chào buổi sáng! Đã đến giờ uống nước',
          'afternoon': 'Nhắc nhở giữa ngày! Hãy uống nước',
          'evening': 'Buổi tối vui vẻ! Đừng quên uống nước',
          'night': 'Trước khi đi ngủ! Hãy uống nước',
          'default': 'Đã đến giờ uống nước!',
          'weather': 'Dự báo thời tiết hôm nay',
        },
        'bodies': {
          'morning': [
            'Chào buổi sáng! Bắt đầu ngày mới với một cốc nước nhé.',
            'Uống nước buổi sáng giúp cơ thể tỉnh táo và khỏe mạnh.',
            'Bắt đầu ngày mới với nước để cơ thể hoạt động tốt nhất.',
          ],
          'afternoon': [
            'Giữa trưa rồi! Đừng quên uống nước để duy trì năng lượng.',
            'Uống nước đều đặn giúp tăng năng lượng và tập trung tốt hơn.',
            'Giữa ngày là thời điểm tốt để bổ sung nước cho cơ thể.',
          ],
          'evening': [
            'Buổi tối vui vẻ! Đừng quên bổ sung nước cho cơ thể.',
            'Uống đủ nước giúp làn da của bạn khỏe mạnh và tươi sáng.',
            'Kết thúc ngày làm việc với một cốc nước mát.',
          ],
          'night': [
            'Trước khi đi ngủ, hãy uống một cốc nước nhỏ.',
            'Ngủ ngon và nhớ uống nước khi thức dậy vào ngày mai nhé!',
            'Uống một ít nước trước khi ngủ giúp cơ thể khỏe mạnh.',
          ],
          'progress': 'Bạn đã uống {progress}% mục tiêu. Còn {remaining}ml nữa!',
          'weather': {
            'hot': 'Thời tiết hôm nay khá nóng, hãy uống nhiều nước hơn nhé!',
            'sunny': 'Trời nắng đấy, uống thêm nước để tránh mất nước nhé!',
            'cold': 'Ngay cả khi trời lạnh, cơ thể vẫn cần nước. Hãy uống ngay!',
            'rainy': 'Trời mưa hôm nay, nhưng đừng quên uống nước nhé!',
            'default': 'Hãy nhớ uống đủ nước dù thời tiết như thế nào!',
          },
          'health': [
            'Nước rất quan trọng cho sức khỏe của bạn. Hãy uống ngay!',
            'Uống đủ nước giúp hệ tiêu hóa hoạt động tốt hơn.',
            'Uống nước thường xuyên giúp giảm nguy cơ đau đầu.',
          ],
        },
      };
    }

    // Default to English
    return {
      'titles': {
        'morning': 'Good morning! Time to hydrate',
        'afternoon': 'Afternoon reminder! Stay hydrated',
        'evening': 'Evening hydration reminder',
        'night': 'Before bed! Don\'t forget to hydrate',
        'default': 'Time to hydrate!',
        'weather': 'Today\'s weather forecast',
      },
      'bodies': {
        'morning': [
          'Good morning! Start your day with a glass of water.',
          'Morning hydration helps wake up your body and mind.',
          'Start your day right with proper hydration.',
        ],
        'afternoon': [
          'Midday reminder! Keep your energy up with proper hydration.',
          'Regular hydration improves energy levels and brain function.',
          'Midday is a great time to replenish your water levels.',
        ],
        'evening': [
          'Evening hydration reminder! Don\'t forget to drink water.',
          'Staying hydrated keeps your skin healthy and glowing.',
          'End your workday with a refreshing glass of water.',
        ],
        'night': [
          'Before bed, have a small glass of water.',
          'Sleep well and remember to hydrate when you wake up tomorrow!',
          'A small amount of water before bed helps your body stay healthy.',
        ],
        'progress': 'You\'ve reached {progress}% of your goal. {remaining}ml to go!',
        'weather': {
          'hot': 'The weather is quite hot today, drink more water!',
          'sunny': 'It\'s sunny outside! Drink extra water to prevent dehydration.',
          'cold': 'Even in cold weather, your body needs water. Take a sip now!',
          'rainy': 'It\'s rainy today, but don\'t forget to stay hydrated!',
          'default': 'Remember to drink enough water regardless of the weather!',
        },
        'health': [
          'Water is essential for your health. Take a sip now!',
          'Proper hydration helps your digestive system work better.',
          'Regular water intake can help prevent headaches.',
        ],
      },
    };
  }

  /// Get body message based on language, progress, and time of day
  String _getBodyMessage(String language, double progress, double remainingAmount, String timeOfDay, String weatherType) {
    final messages = _getLocalizedMessages(language);
    final bodies = messages['bodies'];

    // Create a list of possible messages
    final List<String> possibleMessages = [];

    // Add time-based message
    if (bodies.containsKey(timeOfDay) && bodies[timeOfDay] is List) {
      final timeMessages = bodies[timeOfDay] as List;
      if (timeMessages.isNotEmpty) {
        possibleMessages.add(timeMessages[Random().nextInt(timeMessages.length)]);
      }
    }

    // Add progress message
    if (bodies.containsKey('progress')) {
      final progressTemplate = bodies['progress'];
      final progressMessage = progressTemplate
          .replaceAll('{progress}', (progress * 100).toInt().toString())
          .replaceAll('{remaining}', remainingAmount.toInt().toString());
      possibleMessages.add(progressMessage);
    }

    // Add weather-based message
    if (bodies.containsKey('weather') && bodies['weather'] is Map) {
      final weatherMessages = bodies['weather'] as Map;
      if (weatherMessages.containsKey(weatherType)) {
        possibleMessages.add(weatherMessages[weatherType]);
      } else if (weatherMessages.containsKey('default')) {
        possibleMessages.add(weatherMessages['default']);
      }
    }

    // Add health message
    if (bodies.containsKey('health') && bodies['health'] is List) {
      final healthMessages = bodies['health'] as List;
      if (healthMessages.isNotEmpty) {
        possibleMessages.add(healthMessages[Random().nextInt(healthMessages.length)]);
      }
    }

    // Select a random message from the possible messages
    if (possibleMessages.isEmpty) {
      return language == 'vi' ? 'Đã đến giờ uống nước!' : 'Time to hydrate!';
    }

    return possibleMessages[Random().nextInt(possibleMessages.length)];
  }

  /// Schedule a special morning weather notification at 6 AM
  Future<bool> _scheduleMorningWeatherNotification() async {
    try {
      debugPrint('Scheduling morning weather notification...');

      // Check if notifications are allowed
      final allowed = await _notificationManager.areNotificationsAllowed();
      if (!allowed) {
        final permissionGranted = await _notificationManager.requestPermission();
        if (!permissionGranted) {
          debugPrint('Cannot schedule weather notification: permission denied');
          return false;
        }
      }

      // Create a DateTime for 6 AM today or tomorrow
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 6, 0);

      // If 6 AM has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Get user data for personalization
      final userData = await _getUserData();
      final language = userData?['language'] ?? 'en';

      // Get localized messages
      final messages = _getLocalizedMessages(language);
      final weatherTitle = messages['titles']['weather'];

      // Lấy dữ liệu thời tiết thực từ service
      String weatherType;
      try {
        weatherType = await _getCurrentWeatherType();
        debugPrint('Using actual weather data for morning notification: $weatherType');
      } catch (e) {
        // Fallback to random weather if there's an error
        weatherType = _getRandomWeatherType();
        debugPrint('Using fallback weather data for morning notification: $weatherType');
      }
      final weatherBody = messages['bodies']['weather'][weatherType];

      // Create the notification
      final notification = NotificationFactory.createReminderNotification(
        channelKey: _notificationChannelKey,
        title: weatherTitle,
        body: weatherBody,
        id: 1099, // Special ID for weather notification
        payload: {
          'type': 'weather_reminder',
          'weather_type': weatherType,
        },
      );

      // Schedule the notification
      final success = await _notificationManager.scheduleNotification(notification, scheduledDate);
      if (!success) {
        debugPrint('Failed to schedule morning weather notification');
        return false;
      }

      debugPrint('Successfully scheduled morning weather notification at 06:00 with ID 1099');
      return true;
    } catch (e) {
      debugPrint('Error scheduling morning weather notification: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error scheduling morning weather notification');
      return false;
    }
  }

  /// Get current weather type from weather service
  /// Returns a string representation of the weather condition
  Future<String> _getCurrentWeatherType() async {
    try {
      final weatherResult = await _weatherService.getCurrentWeather();
      return weatherResult.when(
        success: (data) {
          final condition = data.condition;
          debugPrint('Current weather condition: ${condition.name}');

          // Phân loại thời tiết thành các nhóm cho thông báo
          if (condition == WeatherCondition.hot ||
              condition == WeatherCondition.humid ||
              condition == WeatherCondition.sunny) {
            return 'hot';
          } else if (condition == WeatherCondition.partlyCloudy) {
            return 'sunny';
          } else if (condition == WeatherCondition.patchyRainPossible ||
                     condition == WeatherCondition.patchyLightRain ||
                     condition == WeatherCondition.lightRain ||
                     condition == WeatherCondition.moderateRainAtTimes ||
                     condition == WeatherCondition.moderateRain ||
                     condition == WeatherCondition.heavyRainAtTimes ||
                     condition == WeatherCondition.heavyRain ||
                     condition == WeatherCondition.lightRainShower ||
                     condition == WeatherCondition.moderateOrHeavyRainShower ||
                     condition == WeatherCondition.torrentialRainShower ||
                     condition == WeatherCondition.patchyLightRainWithThunder ||
                     condition == WeatherCondition.moderateOrHeavyRainWithThunder ||
                     condition == WeatherCondition.thunderyOutbreaksPossible) {
            return 'rainy';
          } else if (condition == WeatherCondition.patchySnowPossible ||
                     condition == WeatherCondition.patchySleetPossible ||
                     condition == WeatherCondition.patchyFreezingDrizzlePossible ||
                     condition == WeatherCondition.blowingSnow ||
                     condition == WeatherCondition.blizzard ||
                     condition == WeatherCondition.freezingFog ||
                     condition == WeatherCondition.patchyLightDrizzle ||
                     condition == WeatherCondition.lightDrizzle ||
                     condition == WeatherCondition.freezingDrizzle ||
                     condition == WeatherCondition.heavyFreezingDrizzle ||
                     condition == WeatherCondition.lightFreezingRain ||
                     condition == WeatherCondition.moderateOrHeavyFreezingRain ||
                     condition == WeatherCondition.lightSleet ||
                     condition == WeatherCondition.moderateOrHeavySleet ||
                     condition == WeatherCondition.patchyLightSnow ||
                     condition == WeatherCondition.lightSnow ||
                     condition == WeatherCondition.patchyModerateSnow ||
                     condition == WeatherCondition.moderateSnow ||
                     condition == WeatherCondition.patchyHeavySnow ||
                     condition == WeatherCondition.heavySnow ||
                     condition == WeatherCondition.icePellets ||
                     condition == WeatherCondition.lightSleetShowers ||
                     condition == WeatherCondition.moderateOrHeavySleetShowers ||
                     condition == WeatherCondition.lightSnowShowers ||
                     condition == WeatherCondition.moderateOrHeavySnowShowers ||
                     condition == WeatherCondition.lightShowersOfIcePellets ||
                     condition == WeatherCondition.moderateOrHeavyShowersOfIcePellets ||
                     condition == WeatherCondition.patchyLightSnowWithThunder ||
                     condition == WeatherCondition.moderateOrHeavySnowWithThunder) {
            return 'cold';
          } else {            return 'default';
          }
        },
        error: (error) {
          debugPrint('Error getting weather data: $error');
          return 'default';
        },
        loading: () {
          debugPrint('Weather data is loading, using default');
          return 'default';
        },
      );
    } catch (e) {
      debugPrint('Exception getting weather data: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error getting weather data for reminder');
      return 'default';
    }
  }

  /// Fallback method to get a random weather type when actual data is not available
  String _getRandomWeatherType() {
    final weatherTypes = ['hot', 'sunny', 'cold', 'rainy', 'default'];
    return weatherTypes[Random().nextInt(weatherTypes.length)];
  }

  @override
  Future<void> cancelAllReminders() async {
    try {
      // Cancel all water reminder notifications (IDs 1000-1100)
      debugPrint('Cancelling all water reminder notifications...');

      // Cancel standard mode notifications (IDs 1000-1020)
      for (int i = 1000; i <= 1020; i++) {
        await _notificationManager.cancelNotification(i);
      }

      // Cancel interval mode notifications (IDs 1030-1060)
      for (int i = 1030; i <= 1060; i++) {
        await _notificationManager.cancelNotification(i);
      }

      // Cancel custom mode notifications (IDs 1070-1090)
      for (int i = 1070; i <= 1090; i++) {
        await _notificationManager.cancelNotification(i);
      }

      // Cancel special notifications (IDs 1099-1100)
      for (int i = 1099; i <= 1100; i++) {
        await _notificationManager.cancelNotification(i);
      }

      debugPrint('All water reminder notifications cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling reminders: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error cancelling reminders');
    }
  }

  @override
  Future<void> setRemindersEnabled(bool enabled) async {
    final settings = await getReminderSettings();
    await saveReminderSettings(settings.copyWith(enabled: enabled));
  }

  @override
  Future<void> setReminderMode(ReminderMode mode) async {
    try {
      debugPrint('Changing reminder mode from ${_settings?.mode.name ?? 'unknown'} to ${mode.name}');
      final settings = await getReminderSettings();

      // Only update if the mode has actually changed
      if (settings.mode != mode) {
        debugPrint('Mode is different, updating settings and rescheduling reminders');
        await saveReminderSettings(settings.copyWith(mode: mode));
        debugPrint('Reminder mode successfully changed to ${mode.name}');
      } else {
        debugPrint('Mode is already set to ${mode.name}, no changes needed');
      }
    } catch (e) {
      debugPrint('Error setting reminder mode: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error setting reminder mode');
    }
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
