import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/network/config/api_config.dart';
import 'src/core/services/firebase/firebase_remote_config_service.dart';
import 'src/core/services/logger/app_logger.dart';

void main() async {
  // Run the app with error handling using AppLogger
  AppLogger.runZoned(() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize AppLogger
    AppLogger.initialize(true);
    AppLogger.info('Application starting...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized');

    // Initialize Firebase Remote Config
    final remoteConfigService = await FirebaseRemoteConfigService.create();
    AppLogger.info('Firebase Remote Config initialized');

    // Set the API key from Remote Config
    final apiKey = remoteConfigService.getWeatherApiKey();
    ApiConfig.setApiKey(apiKey);
    AppLogger.info('API key configured');

    return runApp(
      // Wrap the app with ProviderScope for Riverpod
      const ProviderScope(
        child: App(),
      ),
    );
  });
}