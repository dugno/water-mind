import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/network/models/api_error.dart';

part 'network_result.freezed.dart';

/// Generic result class for network operations
@freezed
class NetworkResult<T> with _$NetworkResult<T> {
  /// Successful result with data
  const factory NetworkResult.success(T data) = Success<T>;
  
  /// Error result with error details
  const factory NetworkResult.error(ApiError error) = Error<T>;
  
  /// Loading state
  const factory NetworkResult.loading() = Loading<T>;
}
