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
import 'package:water_mind/src/pages/about/about_page.dart';
import 'package:water_mind/src/pages/premium/premium_subscription_page.dart';
import 'package:water_mind/src/pages/privacy_policy/privacy_policy_page.dart';
import 'package:water_mind/src/pages/profile/profile_page.dart';
import 'package:water_mind/src/pages/reminders/reminder_settings_page.dart';
import 'package:water_mind/src/pages/splash/splash_page.dart';

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
        // Splash page - initial route
        AutoRoute(
          path: '/splash',
          page: SplashRoute.page,
          initial: true,
        ),

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
          path: '/main',
          page: MainNavigationRoute.page,
          guards: [GettingStartedGuard()],
        ),

        // Water intake example page
        AutoRoute(
          path: '/example/water-intake',
          page: WaterIntakeExampleRoute.page,
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

        // Privacy Policy page
        AutoRoute(
          path: '/privacy-policy',
          page: PrivacyPolicyRoute.page,
        ),

        // About App page
        AutoRoute(
          path: '/about',
          page: AboutRoute.page,
        ),

        // Premium subscription page
        AutoRoute(
          path: '/premium',
          page: PremiumSubscriptionRoute.page,
        ),
        // Add more routes as needed
      ];
}
