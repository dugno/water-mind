import 'package:water_mind/src/core/network/dio_client.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';

/// Base repository interface
abstract class BaseRepository {
  /// Get data from the API
  Future<NetworkResult<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  });

  /// Post data to the API
  Future<NetworkResult<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  });

  /// Put data to the API
  Future<NetworkResult<T>> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  });

  /// Patch data to the API
  Future<NetworkResult<T>> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  });

  /// Delete data from the API
  Future<NetworkResult<T>> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  });
}

/// Base repository implementation
class BaseRepositoryImpl implements BaseRepository {
  final DioClient _dioClient;

  /// Constructor for BaseRepositoryImpl
  BaseRepositoryImpl(this._dioClient);

  @override
  Future<NetworkResult<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) {
    return _dioClient.get<T>(
      path: path,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  @override
  Future<NetworkResult<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) {
    return _dioClient.post<T>(
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  @override
  Future<NetworkResult<T>> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) {
    return _dioClient.put<T>(
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  @override
  Future<NetworkResult<T>> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) {
    return _dioClient.patch<T>(
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  @override
  Future<NetworkResult<T>> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) {
    return _dioClient.delete<T>(
      path: path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
}
