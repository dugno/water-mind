import 'package:dio/dio.dart';

/// Interceptor for handling authentication
class AuthInterceptor extends Interceptor {
  final String Function()? _getToken;

  /// Constructor for AuthInterceptor
  AuthInterceptor({String Function()? getToken}) : _getToken = getToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getToken?.call();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return super.onRequest(options, handler);
  }
}
