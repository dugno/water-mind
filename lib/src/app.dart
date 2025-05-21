import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/providers/locale_provider.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/notifications/notification_handler_widget.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';

/// The main app widget that uses Riverpod for state management and localization.
class App extends ConsumerWidget {
  /// Creates a new [App] instance.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    // Initialize premium status change notifier
    // This ensures the premium status is watched and updated throughout the app
    ref.watch(premiumStatusChangeNotifierProvider);

    return NotificationHandler(
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Định nghĩa các locale được hỗ trợ
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,

        title: 'Water Mind',

        // Cấu hình router
        routerConfig: router.config(),
      ),
    );
  }
}
