import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Custom interceptor for logging API requests and responses using AppLogger
class LoggingInterceptor extends Interceptor {
  final bool _logRequestBody;
  final bool _logResponseBody;
  final bool _logRequestHeader;
  final bool _logResponseHeader;
  final bool _logError;

  /// Constructor for LoggingInterceptor
  LoggingInterceptor({
    bool logRequestBody = true,
    bool logResponseBody = true,
    bool logRequestHeader = true,
    bool logResponseHeader = true,
    bool logError = true,
  })  : _logRequestBody = logRequestBody,
        _logResponseBody = logResponseBody,
        _logRequestHeader = logRequestHeader,
        _logResponseHeader = logResponseHeader,
        _logError = logError;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestInfo = {
      'method': options.method,
      'path': options.path,
      'baseUrl': options.baseUrl,
      'queryParameters': options.queryParameters,
    };

    AppLogger.info('API Request', requestInfo);

    if (_logRequestHeader) {
      AppLogger.debug('Request Headers', options.headers);
    }

    if (_logRequestBody && options.data != null) {
      try {
        final data = options.data is Map ? options.data : jsonDecode(options.data.toString());
        AppLogger.debug('Request Body', data);
      } catch (e) {
        AppLogger.debug('Request Body (raw)', options.data);
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseInfo = {
      'statusCode': response.statusCode,
      'path': response.requestOptions.path,
      'method': response.requestOptions.method,
    };

    AppLogger.info('API Response', responseInfo);

    if (_logResponseHeader) {
      AppLogger.debug('Response Headers', response.headers.map);
    }

    if (_logResponseBody && response.data != null) {
      try {
        final data = response.data is Map ? response.data : jsonDecode(response.data.toString());
        AppLogger.debug('Response Body', data);
      } catch (e) {
        AppLogger.debug('Response Body (raw)', response.data);
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_logError) {
      final errorInfo = {
        'type': err.type.toString(),
        'path': err.requestOptions.path,
        'method': err.requestOptions.method,
        'statusCode': err.response?.statusCode,
      };

      AppLogger.warning('API Error', errorInfo);

      if (err.response != null && err.response!.data != null) {
        try {
          final data = err.response!.data is Map 
              ? err.response!.data 
              : jsonDecode(err.response!.data.toString());
          AppLogger.debug('Error Response Body', data);
        } catch (e) {
          AppLogger.debug('Error Response Body (raw)', err.response!.data);
        }
      }

      // Log the error message and stack trace for debugging
      if (kDebugMode) {
        AppLogger.reportError(err, err.stackTrace, 'API Error');
      }
    }

    super.onError(err, handler);
  }
}
