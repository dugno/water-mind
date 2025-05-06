import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/services/firebase/firebase_remote_config_service.dart';

part 'firebase_service_provider.g.dart';

/// Provider for Firebase Remote Config Service
@riverpod
Future<FirebaseRemoteConfigService> firebaseRemoteConfigService(
    Ref ref) async {
  return await FirebaseRemoteConfigService.create();
}

/// Provider for the weather API key from Remote Config
@riverpod
Future<String> weatherApiKey(Ref ref) async {
  final remoteConfigService = await ref.watch(firebaseRemoteConfigServiceProvider.future);
  return remoteConfigService.getWeatherApiKey();
}
