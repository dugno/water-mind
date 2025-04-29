import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
/// The main app widget that uses Riverpod for state management and localization.
class App extends ConsumerWidget {
  /// Creates a new [App] instance.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current locale from the provider

    // Get the router from the provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // Set the app's locale based on the current language

      // Add the localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Define the supported locales
      supportedLocales: AppLocalizations.supportedLocales,

      title: 'Water Mind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Configure the router
      routerConfig: router.config(),
    );
  }
}
