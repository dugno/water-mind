import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/user_streak_dao.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/models/user_streak_model.dart';
import 'package:water_mind/src/core/services/streak/streak_service.dart';

/// Provider cho UserStreakDao
final userStreakDaoProvider = Provider<UserStreakDao>((ref) {
  final database = ref.watch(databaseProvider);
  return UserStreakDao(database);
});

/// Provider cho StreakService
final streakServiceProvider = Provider<StreakService>((ref) {
  final dao = ref.watch(userStreakDaoProvider);
  return StreakServiceImpl(dao);
});

/// Provider cho thông tin streak của người dùng
final userStreakProvider = FutureProvider<UserStreakModel?>((ref) async {
  final service = ref.watch(streakServiceProvider);
  return service.getUserStreak();
});

/// Provider kiểm tra xem người dùng có streak trong ngày hôm nay không
final hasTodayStreakProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(streakServiceProvider);
  return service.hasStreakToday();
});

/// Provider cho streak hiện tại
final currentStreakProvider = Provider<int>((ref) {
  final streakAsync = ref.watch(userStreakProvider);
  return streakAsync.value?.currentStreak ?? 0;
});

/// Provider cho streak dài nhất
final longestStreakProvider = Provider<int>((ref) {
  final streakAsync = ref.watch(userStreakProvider);
  return streakAsync.value?.longestStreak ?? 0;
});
