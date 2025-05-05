import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/pages/getting_started/getting_started.dart';
import 'package:water_mind/src/pages/getting_started/models/getting_started_step.dart';
import 'package:water_mind/src/pages/home/home_page.dart';
import 'package:water_mind/src/pages/introduction/introduction.dart';
import 'package:water_mind/src/pages/settings/theme_settings_page.dart';
import 'package:water_mind/src/ui/widgets/hydration/hydration_widgets.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/example/wheel_picker_example.dart';


part 'app_router.gr.dart';

final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
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
        AutoRoute(
          path: '/example/wheel-picker',
          page: WheelPickerExampleRoute.page,
        ),

        // Home page
        AutoRoute(
          path: '/',
          page: HomeRoute.page,
          initial: true,
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

        // Add more routes as needed
      ];
}
