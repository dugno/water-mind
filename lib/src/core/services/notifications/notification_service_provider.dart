import 'awesome_notification_service.dart';
import 'notification_manager.dart';
import 'notification_service_interface.dart';

/// Provider class for notification services.
///
/// This follows the Dependency Inversion Principle by providing
/// abstractions rather than concrete implementations.
class NotificationServiceProvider {
  /// Singleton instance
  static final NotificationServiceProvider _instance = 
      NotificationServiceProvider._internal();

  /// Private constructor
  NotificationServiceProvider._internal();

  /// Factory constructor to return the singleton instance
  factory NotificationServiceProvider() => _instance;

  /// Cached notification service instance
  NotificationServiceInterface? _notificationService;

  /// Cached notification manager instance
  NotificationManager? _notificationManager;

  /// Get the notification service instance.
  ///
  /// This follows the Singleton pattern to ensure only one instance exists.
  NotificationServiceInterface getNotificationService() {
    _notificationService ??= AwesomeNotificationService();
    return _notificationService!;
  }

  /// Get the notification manager instance.
  ///
  /// This follows the Singleton pattern to ensure only one instance exists.
  NotificationManager getNotificationManager() {
    if (_notificationManager == null) {
      final service = getNotificationService();
      _notificationManager = NotificationManager(service);
    }
    return _notificationManager!;
  }

  /// Reset the provider (mainly for testing purposes).
  void reset() {
    _notificationService = null;
    _notificationManager = null;
  }
}
