import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/network/config/api_config.dart';
import 'src/core/services/firebase/firebase_remote_config_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Remote Config
  final remoteConfigService = await FirebaseRemoteConfigService.create();

  // Set the API key from Remote Config
  final apiKey = remoteConfigService.getWeatherApiKey();
  ApiConfig.setApiKey(apiKey);

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: App(),
    ),
  );
}