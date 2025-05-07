import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/routing/auth_guard.dart';
import 'package:water_mind/src/pages/getting_started/getting_started.dart';
import 'package:water_mind/src/pages/getting_started/models/getting_started_step.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/pages/getting_started/summary_page.dart';
import 'package:water_mind/src/pages/history/water_history_page.dart';
import 'package:water_mind/src/pages/home/home_page.dart';
import 'package:water_mind/src/pages/introduction/introduction.dart';
import 'package:water_mind/src/pages/main_navigation_page.dart';
import 'package:water_mind/src/pages/profile/profile_page.dart';
import 'package:water_mind/src/pages/reminders/reminder_settings_page.dart';
import 'package:water_mind/src/pages/settings/theme_settings_page.dart';
import 'package:water_mind/src/ui/widgets/calendar/example/dashed_week_view_example.dart';
import 'package:water_mind/src/ui/widgets/hydration/hydration_widgets.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/example/wheel_picker_example.dart';


part 'app_router.gr.dart';

/// Router provider
final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  /// Constructor
  AppRouter();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/introduction',
          page: IntroductionRoute.page,
        ),

        AutoRoute(
          path: '/getting-started',
          page: GettingStartedRoute.page,
        ),

        // Summary page after getting started
        AutoRoute(
          path: '/summary',
          page: SummaryRoute.page,
        ),

        AutoRoute(
          path: '/example/wheel-picker',
          page: WheelPickerExampleRoute.page,
        ),

        // Main navigation page
        AutoRoute(
          path: '/',
          page: MainNavigationRoute.page,
          initial: true,
          guards: [GettingStartedGuard()],
        ),

        // Water intake example page
        AutoRoute(
          path: '/example/water-intake',
          page: WaterIntakeExampleRoute.page,
        ),

        // Theme settings page
        AutoRoute(
          path: '/settings/theme',
          page: ThemeSettingsRoute.page,
        ),

        // Reminder settings page
        AutoRoute(
          path: '/settings/reminders',
          page: ReminderSettingsRoute.page,
        ),

        // Profile page
        AutoRoute(
          path: '/profile',
          page: ProfileRoute.page,
        ),
        // Add more routes as needed
      ];
}
