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
      showBadge: false,
    ),
    const NotificationChannelModel(
      channelKey: 'alerts_channel',
      channelName: 'Alerts',
      channelDescription: 'Important alerts and time-sensitive notifications',
      importance: 5,
      enableVibration: true,
      playSound: true,
      showBadge: false,
    ),
    const NotificationChannelModel(
      channelKey: 'reminders_channel',
      channelName: 'Reminders',
      channelDescription: 'Reminders and scheduled notifications',
      importance: 4,
      showBadge: false,
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
  Future<bool> initialize() async {
    try {
      // Initialize the notification service
      final initialized = await _notificationService.initialize();

      if (!initialized) {
        debugPrint('Failed to initialize notification service');
        return false;
      }

      // Create default channels
      await _notificationService.createNotificationChannels(_defaultChannels);

      // Check if notifications are allowed
      final allowed = await _notificationService.isNotificationAllowed();

      // Return current permission status
      return allowed;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      return false;
    }
  }

  /// Ensure notifications are allowed, requesting permission if needed.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> ensureNotificationsAllowed() async {
    try {
      // Check if notifications are already allowed
      final allowed = await _notificationService.isNotificationAllowed();
      if (allowed) {
        return true;
      }

      // Request permission if not already granted
      final permissionGranted = await _notificationService.requestNotificationPermission();
      debugPrint('Notification permission ${permissionGranted ? 'granted' : 'denied'}');

      return permissionGranted;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Show a notification immediately.
  /// Returns true if notification was shown, false otherwise.
  Future<bool> showNotification(AppNotificationModel notification) async {
    // Check if notifications are allowed
    final allowed = await ensureNotificationsAllowed();
    if (!allowed) {
      debugPrint('Cannot show notification: permission not granted');
      return false;
    }

    return await _notificationService.showNotification(notification);
  }

  /// Schedule a notification for a future time.
  /// Returns true if notification was scheduled, false otherwise.
  Future<bool> scheduleNotification(
    AppNotificationModel notification,
    DateTime scheduledDate,
  ) async {
    // Check if notifications are allowed
    final allowed = await ensureNotificationsAllowed();
    if (!allowed) {
      debugPrint('Cannot schedule notification: permission not granted');
      return false;
    }

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
