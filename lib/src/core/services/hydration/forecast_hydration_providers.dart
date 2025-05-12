import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/forecast_hydration_dao.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/models/forecast_hydration_model.dart';
import 'package:water_mind/src/core/network/providers/weather_providers.dart';
import 'package:water_mind/src/core/services/hydration/forecast_hydration_repository.dart';
import 'package:water_mind/src/core/services/hydration/forecast_hydration_service.dart';
import 'package:water_mind/src/core/services/hydration/hydration_service_provider.dart';
/// Provider cho ForecastHydrationDao
final forecastHydrationDaoProvider = Provider<ForecastHydrationDao>((ref) {
  final database = ref.watch(databaseProvider);
  return ForecastHydrationDao(database);
});

/// Provider cho ForecastHydrationRepository
final forecastHydrationRepositoryProvider = Provider<ForecastHydrationRepository>((ref) {
  final dao = ref.watch(forecastHydrationDaoProvider);
  return ForecastHydrationRepositoryImpl(dao);
});

/// Provider cho ForecastHydrationService
final forecastHydrationServiceProvider = Provider<ForecastHydrationService>((ref) {
  final weatherRepository = ref.watch(weatherRepositoryV2Provider);
  final hydrationService = ref.watch(hydrationServiceProvider);
  final forecastRepository = ref.watch(forecastHydrationRepositoryProvider);
  final userDataDao = ref.watch(userDataDaoProvider);

  return ForecastHydrationService(
    weatherRepository,
    hydrationService,
    forecastRepository,
    userDataDao,
  );
});

/// Provider cho dự báo lượng nước
final forecastHydrationProvider = FutureProvider.family<List<ForecastHydrationModel>, int>((ref, days) async {
  final service = ref.watch(forecastHydrationServiceProvider);
  return service.getForecastHydration(days: days);
});

/// Provider để tính toán lại dự báo lượng nước
final calculateForecastHydrationProvider = FutureProvider.family<List<ForecastHydrationModel>, int>((ref, days) async {
  final service = ref.watch(forecastHydrationServiceProvider);
  return service.calculateAndSaveForecastHydration(days: days, forceRefresh: true);
});
