import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Guard to check if getting started is completed
class GettingStartedGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Check if getting started is completed
    final isGettingStartedCompleted = KVStoreService.doneGettingStarted;

    // Log the current state for debugging
    debugPrint('GettingStartedGuard: isGettingStartedCompleted = $isGettingStartedCompleted');
    AppLogger.info('GettingStartedGuard: isGettingStartedCompleted = $isGettingStartedCompleted');

    if (isGettingStartedCompleted) {
      // If getting started is completed, continue with the navigation
      AppLogger.info('GettingStartedGuard: Continuing to home page');
      resolver.next(true);
    } else {
      // If getting started is not completed, redirect to getting started page
      AppLogger.info('GettingStartedGuard: Redirecting to getting started page');
      router.push(GettingStartedRoute());
      // Do not continue with the original navigation
      resolver.next(false);
    }
  }
}
