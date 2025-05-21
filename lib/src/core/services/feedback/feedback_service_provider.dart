import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/services/feedback/feedback_service.dart';

part 'feedback_service_provider.g.dart';

/// Provider for the feedback service
@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) {
  return FeedbackService();
}
