import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:water_mind/src/core/network/config/api_config.dart';
import 'package:water_mind/src/core/network/interceptors/error_interceptor.dart';
import 'package:water_mind/src/core/network/models/api_error.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/services/connectivity_service.dart';

/// A client for making HTTP requests using Dio
class DioClient {
  /// The Dio instance
  final Dio _dio;
  
  /// The connectivity service
  final ConnectivityService _connectivityService;

  /// Constructor for DioClient
  DioClient({
    required ConnectivityService connectivityService,
    Dio? dio,
  }) : _connectivityService = connectivityService,
       _dio = dio ?? Dio() {
    _configureDio();
  }

  /// Configure Dio with base options and interceptors
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(ErrorInterceptor());
    
    // Add logger in debug mode
    if (ApiConfig.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }
  }

  /// Make a GET request
  Future<NetworkResult<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    return _request<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// Make a POST request
  Future<NetworkResult<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    return _request<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// Make a PUT request
  Future<NetworkResult<T>> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    return _request<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// Make a PATCH request
  Future<NetworkResult<T>> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic data) fromJson,
  }) async {
    return _request<T>(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// Make a DELETE request
  Future<NetworkResult<T>> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    required T Function(dynamic data) fromJson,
  }) async {
    return _request<T>(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// Generic request method that handles connectivity and errors
  Future<NetworkResult<T>> _request<T>(
    Future<Response> Function() request, {
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      // Check connectivity first
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        return NetworkResult.error(
          const ApiError(
            code: 'NO_CONNECTION',
            message: 'No internet connection',
          ),
        );
      }

      final response = await request();
      final data = fromJson(response.data);
      return NetworkResult.success(data);
    } on DioException catch (e) {
      if (e.error is ApiError) {
        return NetworkResult.error(e.error as ApiError);
      }
      
      return NetworkResult.error(
        ApiError(
          code: 'UNKNOWN_ERROR',
          message: e.message ?? 'An unexpected error occurred',
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return NetworkResult.error(
        ApiError(
          code: 'UNKNOWN_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}
