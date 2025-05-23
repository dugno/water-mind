import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/database/utils/database_service.dart';
import 'src/core/network/config/api_config.dart';
import 'src/core/services/firebase/firebase_remote_config_service.dart';
import 'src/core/services/kv_store/kv_store.dart';
import 'src/core/services/logger/app_logger.dart';
import 'src/core/services/notifications/notification_riverpod_provider.dart';
import 'src/core/services/premium/revenue_cat_service.dart';
import 'src/core/services/reminders/reminder_service_provider.dart';

void main() async {
  // Run the app with error handling using AppLogger
  AppLogger.runZoned(() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize AppLogger
    AppLogger.initialize(true);
    AppLogger.info('Application starting...');

    await KVStoreService.init();
    AppLogger.info('KVStore initialized');

    // Log the detected language
    final detectedLanguage = KVStoreService.appLanguage;
    AppLogger.info('Detected language: $detectedLanguage');

    // Initialize Database Service
    final databaseService = DatabaseService();
    await databaseService.initialize();
    AppLogger.info('Database service initialized');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized');

    // Initialize Firebase Remote Config with error handling
    FirebaseRemoteConfigService? remoteConfigService;
    try {
      remoteConfigService = await FirebaseRemoteConfigService.create();
      AppLogger.info('Firebase Remote Config initialized');

      // Log all Remote Config values for debugging
      final configValues = remoteConfigService.getAllValues();
      AppLogger.debug('Remote Config values loaded', configValues);

      // Set the API key from Remote Config
      final apiKey = remoteConfigService.getWeatherApiKey();
      if (apiKey.isEmpty || apiKey == 'YOUR_WEATHERAPI_KEY') {
        AppLogger.warning('Weather API key is empty or default value');
      }
      ApiConfig.setApiKey(apiKey);
      AppLogger.info('API key configured');
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Failed to initialize Firebase Remote Config');
      // Use default API key as fallback
      ApiConfig.setApiKey(ApiConfig.defaultApiKey);
      AppLogger.warning('Using default API key due to Remote Config failure');
    }

    // Create a ProviderContainer to access providers before the app starts
    final container = ProviderContainer();

    // Initialize the notification manager first
    final notificationManager = container.read(notificationManagerProvider);
    final initialized = await notificationManager.initialize();
    AppLogger.info('Notification manager initialized: $initialized');

    // We don't request notification permission here anymore
    // It will be requested in the summary page when the user completes onboarding

    // Initialize the reminder service
    final reminderService = container.read(reminderServiceProvider);
    await reminderService.initialize();
    AppLogger.info('Reminder service initialized');

    // Initialize RevenueCat for in-app purchases
    try {
      final revenueCatService = RevenueCatService();
      await revenueCatService.initialize();
      AppLogger.info('RevenueCat service initialized');
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace, 'Failed to initialize RevenueCat');
    }

    // Dispose the container as we'll create a new one for the app
    container.dispose();

    // Register a callback to be called when the app is about to be terminated
    // This ensures we properly close the database
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());

    return runApp(
      const ProviderScope(
        observers: [AppLoggerProviderObserver()],
        child: App(),
      ),
    );
  });
}

/// Observer for app lifecycle events to properly handle database closing
class AppLifecycleObserver extends WidgetsBindingObserver {
  final DatabaseService _databaseService = DatabaseService();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is about to be terminated
      // Close the database to prevent any data corruption
      AppLogger.info('App is being terminated. Closing database service...');
      _databaseService.close();
    }
    // Lưu ý: Đã loại bỏ logic xóa dữ liệu cũ khi ứng dụng được khôi phục
  }
}