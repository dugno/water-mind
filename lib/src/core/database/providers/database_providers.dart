import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/database/daos/reminder_settings_dao.dart';
import 'package:water_mind/src/core/database/daos/user_data_dao.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/database/utils/database_service.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Provider cho DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final databaseService = DatabaseService();
  ref.onDispose(() {
    AppLogger.info('Disposing database service provider');
  });
  return databaseService;
});

/// Provider cho AppDatabase
final databaseProvider = Provider<AppDatabase>((ref) {
  if (!DatabaseInitializer.isInitialized) {
    AppLogger.warning('Database not initialized when accessing databaseProvider. Initializing now.');
    throw StateError('Database not initialized. Call DatabaseService.initialize() first.');
  }
  
  final database = DatabaseInitializer.database;
  ref.onDispose(() {
    AppLogger.info('Disposing database provider');
  });
  return database;
});

/// Provider cho WaterIntakeDao
final waterIntakeDaoProvider = Provider<WaterIntakeDao>((ref) {
  final database = ref.watch(databaseProvider);
  return WaterIntakeDao(database);
});

/// Provider cho UserDataDao
final userDataDaoProvider = Provider<UserDataDao>((ref) {
  final database = ref.watch(databaseProvider);
  return UserDataDao(database);
});

/// Provider cho ReminderSettingsDao
final reminderSettingsDaoProvider = Provider<ReminderSettingsDao>((ref) {
  final database = ref.watch(databaseProvider);
  return ReminderSettingsDao(database);
});

/// Provider cho lịch sử uống nước theo ngày
final waterIntakeHistoryProvider = FutureProvider.family<WaterIntakeHistory?, DateTime>((ref, date) async {
  final dao = ref.watch(waterIntakeDaoProvider);
  return dao.getWaterIntakeHistory(date);
});

/// Provider cho tất cả lịch sử uống nước
final allWaterIntakeHistoryProvider = FutureProvider<List<WaterIntakeHistory>>((ref) async {
  final dao = ref.watch(waterIntakeDaoProvider);
  return dao.getAllWaterIntakeHistory();
});

/// Provider cho lịch sử uống nước theo khoảng thời gian
final waterIntakeHistoryRangeProvider = FutureProvider.family<List<WaterIntakeHistory>, ({DateTime? startDate, DateTime? endDate, int? limit, int? offset})>((ref, params) async {
  final dao = ref.watch(waterIntakeDaoProvider);
  return dao.getAllWaterIntakeHistory(
    startDate: params.startDate,
    endDate: params.endDate,
    limit: params.limit,
    offset: params.offset,
  );
});

/// Provider cho dữ liệu người dùng
final userDataProvider = FutureProvider<UserOnboardingModel?>((ref) async {
  final dao = ref.watch(userDataDaoProvider);
  return dao.getUserData();
});

/// Provider cho cài đặt nhắc nhở
final reminderSettingsProvider = FutureProvider<WaterReminderModel?>((ref) async {
  final dao = ref.watch(reminderSettingsDaoProvider);
  return dao.getReminderSettings();
});
