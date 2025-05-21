import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_model.g.dart';
part 'feedback_model.freezed.dart';

/// Model for user feedback
@freezed
class FeedbackModel with _$FeedbackModel {
  /// Constructor
  const factory FeedbackModel({
    /// Unique ID for the feedback
    String? id,
    
    /// The feedback message from the user
    required String message,
    
    /// User ID or identifier (optional)
    String? userId,
    
    /// App version when feedback was submitted
    String? appVersion,
    
    /// Device information
    String? deviceInfo,
    
    /// User's selected language
    String? language,
    
    /// Timestamp when feedback was created
    @Default(null) DateTime? createdAt,
  }) = _FeedbackModel;

  /// Create from JSON
  factory FeedbackModel.fromJson(Map<String, dynamic> json) => _$FeedbackModelFromJson(json);
}
