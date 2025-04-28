import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'notification_channel_model.dart';
import 'notification_model.dart';
import 'notification_service_interface.dart';

/// Manager class for handling notifications.
///
/// This class follows the Single Responsibility Principle by focusing only on
/// managing notifications and providing a clean API for the rest of the app.
class NotificationManager {
  /// The notification service implementation
  final NotificationServiceInterface _notificationService;

  /// Stream controllers for notification events
  final StreamController<ReceivedAction> _actionController =
      StreamController<ReceivedAction>.broadcast();
  final StreamController<ReceivedNotification> _displayController =
      StreamController<ReceivedNotification>.broadcast();

  /// Default channels for the application
  final List<NotificationChannelModel> _defaultChannels = [
    const NotificationChannelModel(
      channelKey: 'general_channel',
      channelName: 'General Notifications',
      channelDescription: 'General notifications for the app',
      importance: 3,
    ),
    const NotificationChannelModel(
      channelKey: 'alerts_channel',
      channelName: 'Alerts',
      channelDescription: 'Important alerts and time-sensitive notifications',
      importance: 5,
      enableVibration: true,
      playSound: true,
    ),
    const NotificationChannelModel(
      channelKey: 'reminders_channel',
      channelName: 'Reminders',
      channelDescription: 'Reminders and scheduled notifications',
      importance: 4,
    ),
  ];

  /// Stream of notification actions (taps)
  Stream<ReceivedAction> get onActionStream => _actionController.stream;

  /// Stream of displayed notifications
  Stream<ReceivedNotification> get onDisplayStream => _displayController.stream;

  /// Creates a new [NotificationManager] instance.
  NotificationManager(this._notificationService) {
    // Listen to notification actions
    _notificationService.actionStream.listen((action) {
      _actionController.add(action);
    });

    // Listen to displayed notifications
    _notificationService.displayedStream.listen((notification) {
      _displayController.add(notification);
    });
  }

  /// Initialize the notification system.
  ///
  /// This should be called early in the app lifecycle, typically in main.dart.
  Future<void> initialize() async {
    try {
      // Initialize the notification service
      final initialized = await _notificationService.initialize();

      if (!initialized) {
        debugPrint('Failed to initialize notification service');
        return;
      }

      // Create default channels
      await _notificationService.createNotificationChannels(_defaultChannels);

      // Request permission if not already granted
      final allowed = await _notificationService.isNotificationAllowed();
      if (!allowed) {
        final permissionGranted = await _notificationService.requestNotificationPermission();
        debugPrint('Notification permission ${permissionGranted ? 'granted' : 'denied'}');
      }
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Show a notification immediately.
  Future<bool> showNotification(AppNotificationModel notification) async {
    return await _notificationService.showNotification(notification);
  }

  /// Schedule a notification for a future time.
  Future<bool> scheduleNotification(
    AppNotificationModel notification,
    DateTime scheduledDate,
  ) async {
    return await _notificationService.scheduleNotification(
      notification,
      scheduledDate,
    );
  }

  /// Cancel a specific notification by ID.
  Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Create a custom notification channel.
  Future<void> createChannel(NotificationChannelModel channel) async {
    await _notificationService.createNotificationChannel(channel);
  }

  /// Check if notifications are allowed.
  Future<bool> areNotificationsAllowed() async {
    return await _notificationService.isNotificationAllowed();
  }

  /// Request permission to show notifications.
  Future<bool> requestPermission() async {
    return await _notificationService.requestNotificationPermission();
  }

  /// Dispose of resources used by the notification manager.
  Future<void> dispose() async {
    await _actionController.close();
    await _displayController.close();
    await _notificationService.dispose();
  }
}
