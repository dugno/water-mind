import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/network/dio_client.dart';
import 'package:water_mind/src/core/network/services/connectivity_service.dart';

part 'network_providers.g.dart';

/// Provider for ConnectivityService
@riverpod
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityServiceImpl();
}

/// Provider for Dio instance
@riverpod
Dio dio(Ref ref) {
  return Dio();
}

/// Provider for DioClient
@riverpod
DioClient dioClient(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final dio = ref.watch(dioProvider);

  return DioClient(
    connectivityService: connectivityService,
    dio: dio,
  );
}
