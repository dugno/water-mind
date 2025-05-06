import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/network/providers/network_providers.dart';
import 'package:water_mind/src/core/network/repositories/weather_repository.dart';

part 'repository_providers.g.dart';

/// Provider for WeatherRepository
@riverpod
WeatherRepository weatherRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WeatherRepositoryImpl(dioClient);
}

