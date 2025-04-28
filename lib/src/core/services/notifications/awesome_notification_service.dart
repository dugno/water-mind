import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'notification_channel_model.dart';
import 'notification_model.dart';
import 'notification_service_interface.dart';
import 'notification_service_provider.dart';

/// Implementation of [NotificationServiceInterface] using the awesome_notifications package.
///
/// This class follows the Dependency Inversion Principle by depending on
/// abstractions (NotificationServiceInterface) rather than concrete implementations.
class AwesomeNotificationService implements NotificationServiceInterface {
  /// The awesome notifications instance.
  final AwesomeNotifications _awesomeNotifications;

  /// Stream controllers for notification events
  final StreamController<ReceivedAction> _actionController =
      StreamController<ReceivedAction>.broadcast();
  final StreamController<ReceivedNotification> _createdController =
      StreamController<ReceivedNotification>.broadcast();
  final StreamController<ReceivedNotification> _displayedController =
      StreamController<ReceivedNotification>.broadcast();

  /// Creates a new [AwesomeNotificationService] instance.
  ///
  /// By default, it uses the global [AwesomeNotifications] instance,
  /// but a custom instance can be provided for testing.
  AwesomeNotificationService({AwesomeNotifications? awesomeNotifications})
      : _awesomeNotifications = awesomeNotifications ?? AwesomeNotifications() {

    // Set up listeners for notification events
    _awesomeNotifications.setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived
    );
  }

  // Callback methods for notification events
  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction receivedAction) async {
    // This method needs to be static for proper registration
    // We'll use a global instance to forward the events
    final service = NotificationServiceProvider().getNotificationService() as AwesomeNotificationService;
    service._actionController.add(receivedAction);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {
    // This method needs to be static for proper registration
    final service = NotificationServiceProvider().getNotificationService() as AwesomeNotificationService;
    service._createdController.add(receivedNotification);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {
    // This method needs to be static for proper registration
    final service = NotificationServiceProvider().getNotificationService() as AwesomeNotificationService;
    service._displayedController.add(receivedNotification);
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceived(ReceivedAction receivedAction) async {
    // Handle dismiss action if needed
    // This method needs to be static for proper registration
  }

  @override
  Future<bool> initialize() async {
    return await _awesomeNotifications.initialize(
      null, // No default icon is set here, should be set in the app
      [
        // Default channel required by the package
        NotificationChannel(
          channelKey: 'general_channel',
          channelName: 'General Notifications',
          channelDescription: 'General notifications for the app',
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          channelShowBadge: true,
        ),
      ],
      debug: true, // Set to false in production
    );
  }

  @override
  Future<void> createNotificationChannel(NotificationChannelModel channel) async {
    await _awesomeNotifications.setChannel(
      NotificationChannel(
        channelKey: channel.channelKey,
        channelName: channel.channelName,
        channelDescription: channel.channelDescription,
        importance: NotificationImportance.values[channel.importance],
        defaultPrivacy: NotificationPrivacy.Private,
        enableVibration: channel.enableVibration,
        enableLights: channel.enableLights,
        playSound: channel.playSound,
        channelShowBadge: channel.showBadge,
      ),
    );
  }

  @override
  Future<void> createNotificationChannels(List<NotificationChannelModel> channels) async {
    for (final channel in channels) {
      await createNotificationChannel(channel);
    }
  }

  @override
  Future<bool> showNotification(AppNotificationModel notification) async {
    return await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: notification.id,
        channelKey: notification.channelKey,
        title: notification.title,
        body: notification.body,
        category: notification.category != null
            ? NotificationCategory.values.firstWhere(
                (e) => e.name == notification.category,
                orElse: () => NotificationCategory.Message,
              )
            : null,
        payload: notification.payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  Future<bool> scheduleNotification(
    AppNotificationModel notification,
    DateTime scheduledDate,
  ) async {
    return await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: notification.id,
        channelKey: notification.channelKey,
        title: notification.title,
        body: notification.body,
        category: notification.category != null
            ? NotificationCategory.values.firstWhere(
                (e) => e.name == notification.category,
                orElse: () => NotificationCategory.Message,
              )
            : null,
        payload: notification.payload,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _awesomeNotifications.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _awesomeNotifications.cancelAll();
  }

  @override
  Future<bool> isNotificationAllowed() async {
    return await _awesomeNotifications.isNotificationAllowed();
  }

  @override
  Future<bool> requestNotificationPermission() async {
    return await _awesomeNotifications.requestPermissionToSendNotifications();
  }



  @override
  Stream<ReceivedAction> get actionStream => _actionController.stream;

  @override
  Stream<ReceivedNotification> get createdStream => _createdController.stream;

  @override
  Stream<ReceivedNotification> get displayedStream => _displayedController.stream;

  @override
  Future<void> dispose() async {
    // Close stream controllers if they're not closed already
    if (!_actionController.isClosed) {
      await _actionController.close();
    }
    if (!_createdController.isClosed) {
      await _createdController.close();
    }
    if (!_displayedController.isClosed) {
      await _displayedController.close();
    }

    // Dispose the awesome notifications instance
    await _awesomeNotifications.dispose();
  }
}
