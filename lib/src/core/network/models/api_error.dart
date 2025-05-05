import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

/// Model for API errors
@freezed
class ApiError with _$ApiError {
  /// Default constructor for ApiError
  const factory ApiError({
    required String code,
    required String message,
    dynamic data,
  }) = _ApiError;

  /// Factory constructor for creating an ApiError from JSON
  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
}
