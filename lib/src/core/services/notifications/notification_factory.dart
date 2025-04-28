import 'notification_model.dart';

/// Factory class for creating common notification types.
///
/// This follows the Factory pattern to encapsulate notification creation logic.
class NotificationFactory {
  /// Counter for generating unique notification IDs
  static int _notificationIdCounter = 0;

  /// Get a unique notification ID
  static int getUniqueId() {
    return _notificationIdCounter++;
  }

  /// Create a basic notification
  static AppNotificationModel createBasicNotification({
    required String channelKey,
    required String title,
    required String body,
    Map<String, String>? payload,
    int? id,
  }) {
    return AppNotificationModel(
      id: id ?? getUniqueId(),
      channelKey: channelKey,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Create an alert notification (high importance)
  static AppNotificationModel createAlertNotification({
    required String channelKey,
    required String title,
    required String body,
    Map<String, String>? payload,
    int? id,
  }) {
    return AppNotificationModel(
      id: id ?? getUniqueId(),
      channelKey: channelKey,
      title: title,
      body: body,
      payload: payload,
      importance: 5, // Max importance
      category: 'Alarm',
    );
  }

  /// Create an information notification (medium importance)
  static AppNotificationModel createInfoNotification({
    required String channelKey,
    required String title,
    required String body,
    Map<String, String>? payload,
    int? id,
  }) {
    return AppNotificationModel(
      id: id ?? getUniqueId(),
      channelKey: channelKey,
      title: title,
      body: body,
      payload: payload,
      importance: 3, // Medium importance
      category: 'Status',
    );
  }

  /// Create a reminder notification
  static AppNotificationModel createReminderNotification({
    required String channelKey,
    required String title,
    required String body,
    Map<String, String>? payload,
    int? id,
  }) {
    return AppNotificationModel(
      id: id ?? getUniqueId(),
      channelKey: channelKey,
      title: title,
      body: body,
      payload: payload,
      importance: 4, // High importance
      category: 'Reminder',
    );
  }
}
