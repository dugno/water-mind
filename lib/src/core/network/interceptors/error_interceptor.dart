import 'dart:io';

import 'package:dio/dio.dart';
import 'package:water_mind/src/core/network/models/api_error.dart';

/// Interceptor for handling errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ApiError apiError = _handleError(err);
    
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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          code: 'TIMEOUT_ERROR',
          message: 'Connection timeout. Please try again later.',
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return const ApiError(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled',
        );
      case DioExceptionType.connectionError:
        return const ApiError(
          code: 'CONNECTION_ERROR',
          message: 'No internet connection',
        );
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const ApiError(
            code: 'SOCKET_ERROR',
            message: 'No internet connection',
          );
        }
        return const ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred',
        );
      default:
        return const ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred',
        );
    }
  }

  ApiError _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    
    switch (statusCode) {
      case 400:
        return ApiError(
          code: 'BAD_REQUEST',
          message: 'Bad request',
          data: data,
        );
      case 401:
        return ApiError(
          code: 'UNAUTHORIZED',
          message: 'Unauthorized access',
          data: data,
        );
      case 403:
        return ApiError(
          code: 'FORBIDDEN',
          message: 'Access forbidden',
          data: data,
        );
      case 404:
        return ApiError(
          code: 'NOT_FOUND',
          message: 'Resource not found',
          data: data,
        );
      case 500:
      case 501:
      case 502:
      case 503:
        return ApiError(
          code: 'SERVER_ERROR',
          message: 'Internal server error',
          data: data,
        );
      default:
        return ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred',
          data: data,
        );
    }
  }
}
