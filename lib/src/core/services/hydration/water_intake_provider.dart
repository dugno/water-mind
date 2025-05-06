import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Provider cho database
/// Uses the singleton instance from DatabaseInitializer
final databaseProvider = Provider<AppDatabase>((ref) {
  // Get the singleton instance instead of creating a new one
  if (!DatabaseInitializer.isInitialized) {
    AppLogger.warning('Database not initialized when accessing databaseProvider. Initializing now.');
    // This is a fallback and should not happen in normal operation
    // The database should be initialized in main.dart before any providers are accessed
    DatabaseInitializer.initialize();
  }

  // We don't close the database on dispose since it's a singleton
  // It will be closed when the app is terminated
  return DatabaseInitializer.database;
});

/// Provider cho water intake DAO
final waterIntakeDaoProvider = Provider<WaterIntakeDao>((ref) {
  final database = ref.watch(databaseProvider);
  return WaterIntakeDao(database);
});

/// Provider cho water intake repository
final waterIntakeRepositoryProvider = Provider<WaterIntakeRepository>((ref) {
  final dao = ref.watch(waterIntakeDaoProvider);
  return DriftWaterIntakeRepository(dao);
});

/// Provider cho lịch sử uống nước theo ngày
final waterIntakeHistoryProvider = FutureProvider.family<WaterIntakeHistory?, DateTime>((ref, date) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return repository.getWaterIntakeHistory(date);
});

/// Provider cho tất cả lịch sử uống nước
final allWaterIntakeHistoryProvider = FutureProvider<List<WaterIntakeHistory>>((ref) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return repository.getAllWaterIntakeHistory();
});
