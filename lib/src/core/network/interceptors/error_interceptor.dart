import 'dart:io';

import 'package:dio/dio.dart';
import 'package:water_mind/src/core/network/models/api_error.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Interceptor for handling errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ApiError apiError = _handleError(err);

    // Log the error with AppLogger
    AppLogger.warning(
      'API Error: ${apiError.code}',
      {
        'message': apiError.message,
        'path': err.requestOptions.path,
        'method': err.requestOptions.method,
      },
    );

    // Create a new error with the custom error model
    final newError = DioException(
      requestOptions: err.requestOptions,
      error: apiError,
      response: err.response,
      type: err.type,
      message: apiError.message,
    );

    return handler.reject(newError);
  }

  ApiError _handleError(DioException error) {
    ApiError apiError;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiError = const ApiError(
          code: 'TIMEOUT_ERROR',
          message: 'Connection timeout. Please try again later.',
        );
        AppLogger.debug('API Timeout', {'type': error.type.toString()});
        break;

      case DioExceptionType.badResponse:
        apiError = _handleResponseError(error);
        break;

      case DioExceptionType.cancel:
        apiError = const ApiError(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled',
        );
        AppLogger.debug('API Request Cancelled', {'path': error.requestOptions.path});
        break;

      case DioExceptionType.connectionError:
        apiError = const ApiError(
          code: 'CONNECTION_ERROR',
          message: 'No internet connection',
        );
        AppLogger.debug('API Connection Error', {'error': error.message});
        break;

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          apiError = const ApiError(
            code: 'SOCKET_ERROR',
            message: 'No internet connection',
          );
          AppLogger.debug('API Socket Error', {'error': error.error.toString()});
        } else {
          apiError = const ApiError(
            code: 'UNKNOWN_ERROR',
            message: 'An unexpected error occurred',
          );
          AppLogger.debug('API Unknown Error', {'error': error.error.toString()});
        }
        break;

      default:
        apiError = const ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred',
        );
        AppLogger.debug('API Default Error Case', {'type': error.type.toString()});
    }

    return apiError;
  }

  ApiError _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final path = error.requestOptions.path;
    ApiError apiError;

    switch (statusCode) {
      case 400:
        apiError = ApiError(
          code: 'BAD_REQUEST',
          message: 'Bad request',
          data: data,
        );
        AppLogger.debug('API Bad Request', {'path': path, 'data': data});
        break;

      case 401:
        apiError = ApiError(
          code: 'UNAUTHORIZED',
          message: 'Unauthorized access',
          data: data,
        );
        AppLogger.debug('API Unauthorized', {'path': path});
        break;

      case 403:
        apiError = ApiError(
          code: 'FORBIDDEN',
          message: 'Access forbidden',
          data: data,
        );
        AppLogger.debug('API Forbidden', {'path': path});
        break;

      case 404:
        apiError = ApiError(
          code: 'NOT_FOUND',
          message: 'Resource not found',
          data: data,
        );
        AppLogger.debug('API Not Found', {'path': path});
        break;

      case 500:
      case 501:
      case 502:
      case 503:
        apiError = ApiError(
          code: 'SERVER_ERROR',
          message: 'Internal server error',
          data: data,
        );
        AppLogger.debug('API Server Error', {'statusCode': statusCode, 'path': path});
        break;

      default:
        apiError = ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred',
          data: data,
        );
        AppLogger.debug('API Unknown Status Code', {'statusCode': statusCode, 'path': path});
    }

    return apiError;
  }
}
