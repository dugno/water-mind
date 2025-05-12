import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';

// Sử dụng các provider từ database_providers.dart

/// Provider cho water intake repository
final waterIntakeRepositoryProvider = Provider<WaterIntakeRepository>((ref) {
  final dao = ref.watch(waterIntakeDaoProvider);
  return DriftWaterIntakeRepository(dao, ref);
});

/// Provider cho lịch sử uống nước theo khoảng thời gian
final waterIntakeHistoryRangeProvider = FutureProvider.family<List<WaterIntakeHistory>, ({DateTime? startDate, DateTime? endDate, int? limit, int? offset})>((ref, params) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return repository.getAllWaterIntakeHistory(
    startDate: params.startDate,
    endDate: params.endDate,
    limit: params.limit,
    offset: params.offset,
  );
});
