import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/notifications/notification_riverpod_provider.dart';
import 'reminder_service_interface.dart';
import 'water_reminder_service.dart';
import 'models/water_reminder_model.dart';

/// Provider for the reminder service
final reminderServiceProvider = Provider<ReminderServiceInterface>((ref) {
  final notificationManager = ref.watch(notificationManagerProvider);

  return WaterReminderService(
    notificationManager: notificationManager,
  );
});

/// Provider for the current reminder settings
final reminderSettingsProvider = FutureProvider<WaterReminderModel>((ref) async {
  final reminderService = ref.watch(reminderServiceProvider);
  return await reminderService.getReminderSettings();
});
