import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Generic API response model
@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  /// Default constructor for ApiResponse
  const factory ApiResponse({
    required bool success,
    String? message,
    T? data,
    @Default({}) Map<String, dynamic> meta,
  }) = _ApiResponse<T>;

  /// Factory constructor for creating an ApiResponse from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}
