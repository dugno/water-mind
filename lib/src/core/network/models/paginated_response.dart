import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';
part 'paginated_response.g.dart';

/// Model for paginated API responses
@Freezed(genericArgumentFactories: true)
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  /// Default constructor for PaginatedResponse
  const factory PaginatedResponse({
    required List<T> data,
    required PaginationMeta meta,
  }) = _PaginatedResponse<T>;

  /// Factory constructor for creating a PaginatedResponse from JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);
}

/// Model for pagination metadata
@freezed
class PaginationMeta with _$PaginationMeta {
  /// Default constructor for PaginationMeta
  const factory PaginationMeta({
    required int currentPage,
    required int lastPage,
    required int perPage,
    required int total,
    String? nextPageUrl,
    String? prevPageUrl,
  }) = _PaginationMeta;

  /// Factory constructor for creating a PaginationMeta from JSON
  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}
