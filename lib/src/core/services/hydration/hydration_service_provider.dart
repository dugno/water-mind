import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hydration_calculation_service.dart';
import 'hydration_service_interface.dart';

/// Provider for the hydration calculation service
final hydrationServiceProvider = Provider<HydrationServiceInterface>((ref) {
  return HydrationCalculationService();
});

/// Provider for calculating hydration from user model
final userHydrationProvider = Provider.family((ref, dynamic userModel) {
  final hydrationService = ref.watch(hydrationServiceProvider);
  return hydrationService.calculateFromUserModel(userModel);
});
