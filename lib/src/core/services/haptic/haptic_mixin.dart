import 'haptic_service.dart';

/// Mixin để dễ dàng thêm haptic feedback vào widgets
mixin HapticFeedbackMixin {
  /// Service instance
  final _hapticService = HapticService.instance;

  /// Phát haptic feedback
  void haptic(HapticFeedbackType type) {
    _hapticService.feedback(type);
  }
}