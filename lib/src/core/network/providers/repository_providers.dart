import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/network/providers/network_providers.dart';
import 'package:water_mind/src/core/network/repositories/weather_repository.dart';

part 'repository_providers.g.dart';

/// Provider for WeatherRepository
@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WeatherRepositoryImpl(dioClient);
}

