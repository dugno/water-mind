import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service_interface.dart';
import 'notification_service_provider.dart';

/// Riverpod provider for the notification service
final notificationServiceProvider = Provider<NotificationServiceInterface>((ref) {
  // Use the existing singleton provider to get the notification service
  return NotificationServiceProvider().getNotificationService();
});

/// Riverpod provider for the notification manager
final notificationManagerProvider = Provider((ref) {
  // Use the existing singleton provider to get the notification manager
  return NotificationServiceProvider().getNotificationManager();
});
