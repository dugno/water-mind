import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'hydration_calculation_service.dart';
import 'hydration_service_interface.dart';
import 'premium_hydration_calculation_service.dart';

/// Provider for the base hydration calculation service
final baseHydrationServiceProvider = Provider<HydrationCalculationService>((ref) {
  return HydrationCalculationService();
});

/// Provider for the hydration calculation service with premium features
final hydrationServiceProvider = Provider<HydrationServiceInterface>((ref) {
  final baseService = ref.watch(baseHydrationServiceProvider);
  final premiumService = ref.watch(premiumServiceProvider);
  return PremiumHydrationCalculationService(baseService, premiumService);
});

/// Provider for calculating hydration from user model
final userHydrationProvider = Provider.family((ref, dynamic userModel) {
  final hydrationService = ref.watch(hydrationServiceProvider);
  return hydrationService.calculateFromUserModel(userModel);
});
