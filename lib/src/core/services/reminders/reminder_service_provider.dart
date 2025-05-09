import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/reminder_settings_dao.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/services/notifications/notification_riverpod_provider.dart';
import 'package:water_mind/src/core/services/reminders/reminder_provider.dart';
import 'package:water_mind/src/core/services/reminders/reminder_repository.dart';
import 'reminder_service_interface.dart';
import 'water_reminder_service.dart';

/// Provider cho reminder service
final reminderServiceProvider = Provider<ReminderServiceInterface>((ref) {
  final notificationManager = ref.watch(notificationManagerProvider);
  final reminderRepository = ref.watch(reminderRepositoryProvider);

  return WaterReminderService(
    notificationManager: notificationManager,
    reminderRepository: reminderRepository,
  );
});

/// Tạo một instance mới của WaterReminderService
/// Được sử dụng cho migration và testing
class ReminderServiceProvider {
  /// Tạo một instance mới của WaterReminderService
  static ReminderServiceInterface createWaterReminderService() {
    // Tạo một NotificationManager mới
    final notificationManager = NotificationManagerProvider.createNotificationManager();

    // Tạo một ReminderRepository mới
    final dao = ReminderSettingsDao(DatabaseInitializer.database);
    final reminderRepository = ReminderRepositoryImpl(dao);

    // Tạo một WaterReminderService mới
    return WaterReminderService(
      notificationManager: notificationManager,
      reminderRepository: reminderRepository,
    );
  }
}

// Sử dụng provider từ database_providers.dart và reminder_provider.dart
