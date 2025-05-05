import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/services/firebase/firebase_remote_config_service.dart';

part 'firebase_service_provider.g.dart';

/// Provider for Firebase Remote Config Service
@riverpod
Future<FirebaseRemoteConfigService> firebaseRemoteConfigService(
    FirebaseRemoteConfigServiceRef ref) async {
  return await FirebaseRemoteConfigService.create();
}

/// Provider for the weather API key from Remote Config
@riverpod
Future<String> weatherApiKey(WeatherApiKeyRef ref) async {
  final remoteConfigService = await ref.watch(firebaseRemoteConfigServiceProvider.future);
  return remoteConfigService.getWeatherApiKey();
}
