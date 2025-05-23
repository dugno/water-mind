import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/daily_water_summary_dao.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/models/daily_water_summary.dart';
import 'package:water_mind/src/core/services/hydration/daily_water_summary_repository.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_change_notifier.dart';

/// Provider cho daily water summary dao
final dailyWaterSummaryDaoProvider = Provider<DailyWaterSummaryDao>((ref) {
  final database = ref.watch(databaseProvider);
  return DailyWaterSummaryDao(database);
});

/// Provider cho daily water summary repository
final dailyWaterSummaryRepositoryProvider = Provider<DailyWaterSummaryRepository>((ref) {
  final dao = ref.watch(dailyWaterSummaryDaoProvider);
  return DailyWaterSummaryRepositoryImpl(dao);
});

/// Provider để lấy tổng lượng nước uống theo ngày
final dailyWaterSummaryProvider = FutureProvider.family<DailyWaterSummary?, DateTime>((ref, date) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);
  
  final repository = ref.watch(dailyWaterSummaryRepositoryProvider);
  return repository.getDailyWaterSummary(date);
});

/// Provider để lấy tất cả tổng lượng nước uống
final allDailyWaterSummariesProvider = FutureProvider<List<DailyWaterSummary>>((ref) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);
  
  final repository = ref.watch(dailyWaterSummaryRepositoryProvider);
  return repository.getAllDailyWaterSummaries();
});

/// Provider để lấy tổng lượng nước uống trong một khoảng thời gian
final dailyWaterSummaryRangeProvider = FutureProvider.family<List<DailyWaterSummary>, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);
  
  final repository = ref.watch(dailyWaterSummaryRepositoryProvider);
  return repository.getAllDailyWaterSummaries(
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider để lấy tổng lượng nước uống trong 7 ngày gần nhất
final weeklyWaterSummaryProvider = FutureProvider<List<DailyWaterSummary>>((ref) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);
  
  final repository = ref.watch(dailyWaterSummaryRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day - 6);
  return repository.getAllDailyWaterSummaries(
    startDate: startDate,
    endDate: now,
  );
});

/// Provider để lấy tổng lượng nước uống trong 30 ngày gần nhất
final monthlyWaterSummaryProvider = FutureProvider<List<DailyWaterSummary>>((ref) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);
  
  final repository = ref.watch(dailyWaterSummaryRepositoryProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day - 29);
  return repository.getAllDailyWaterSummaries(
    startDate: startDate,
    endDate: now,
  );
});
