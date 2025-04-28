import 'package:awesome_notifications/awesome_notifications.dart';
import 'notification_channel_model.dart';
import 'notification_model.dart';

/// Interface for notification services.
///
/// This follows the Interface Segregation Principle by defining
/// a focused set of methods that notification services must implement.
abstract class NotificationServiceInterface {
  /// Initialize the notification service.
  ///
  /// This should be called early in the app lifecycle, typically in main.dart.
  Future<bool> initialize();

  /// Create a notification channel.
  ///
  /// Channels are used to categorize notifications and allow users
  /// to control notification behavior at a channel level.
  Future<void> createNotificationChannel(NotificationChannelModel channel);

  /// Create multiple notification channels at once.
  Future<void> createNotificationChannels(List<NotificationChannelModel> channels);

  /// Show a simple notification.
  Future<bool> showNotification(AppNotificationModel notification);

  /// Schedule a notification to be shown at a specific time.
  Future<bool> scheduleNotification(
    AppNotificationModel notification,
    DateTime scheduledDate,
  );

  /// Cancel a specific notification by its ID.
  Future<void> cancelNotification(int id);

  /// Cancel all notifications.
  Future<void> cancelAllNotifications();

  /// Check if notifications are allowed.
  Future<bool> isNotificationAllowed();

  /// Request permission to show notifications.
  Future<bool> requestNotificationPermission();

  /// Listen for notification actions (taps).
  Stream<ReceivedAction> get actionStream;

  /// Listen for notification creation events.
  Stream<ReceivedNotification> get createdStream;

  /// Listen for notification display events.
  Stream<ReceivedNotification> get displayedStream;

  /// Dispose of any resources used by the notification service.
  Future<void> dispose();
}
