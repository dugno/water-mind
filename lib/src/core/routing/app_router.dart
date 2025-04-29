import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pages/introduction/introduction.dart';

part 'app_router.gr.dart';

final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        // Introduction page (initial route)
        AutoRoute(
          path: '/',
          page: IntroductionRoute.page,
          initial: true,
        ),


        // Add more routes as needed
      ];
}
