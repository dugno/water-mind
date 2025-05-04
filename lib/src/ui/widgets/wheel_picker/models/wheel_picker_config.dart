import 'package:water_mind/src/core/services/haptic/haptic_service.dart';

/// Configuration for the wheel picker
class WheelPickerConfig {
  /// The height of the wheel picker
  final double height;

  /// The height of each item in the wheel picker
  final double itemHeight;

  /// The number of items visible in the wheel picker
  final int visibleItemCount;

  /// The diameter of the wheel
  final double diameterRatio;

  /// The perspective of the wheel
  final double perspective;

  /// Whether to use haptic feedback
  final bool useHapticFeedback;

  /// The type of haptic feedback to use when scrolling
  final HapticFeedbackType scrollHapticType;

  /// The type of haptic feedback to use when selecting an item
  final HapticFeedbackType selectionHapticType;

  /// Whether to use platform-specific styling
  final bool usePlatformStyling;

  /// The animation duration for the wheel picker
  final Duration animationDuration;

  /// Constructor
  const WheelPickerConfig({
    this.height = 200.0,
    this.itemHeight = 40.0,
    this.visibleItemCount = 5,
    this.diameterRatio = 1.5,
    this.perspective = 0.01,
    this.useHapticFeedback = true,
    this.scrollHapticType = HapticFeedbackType.light,
    this.selectionHapticType = HapticFeedbackType.medium,
    this.usePlatformStyling = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// Create a copy of this config with the given fields replaced
  WheelPickerConfig copyWith({
    double? height,
    double? itemHeight,
    int? visibleItemCount,
    double? diameterRatio,
    double? perspective,
    bool? useHapticFeedback,
    HapticFeedbackType? scrollHapticType,
    HapticFeedbackType? selectionHapticType,
    bool? usePlatformStyling,
    Duration? animationDuration,
  }) {
    return WheelPickerConfig(
      height: height ?? this.height,
      itemHeight: itemHeight ?? this.itemHeight,
      visibleItemCount: visibleItemCount ?? this.visibleItemCount,
      diameterRatio: diameterRatio ?? this.diameterRatio,
      perspective: perspective ?? this.perspective,
      useHapticFeedback: useHapticFeedback ?? this.useHapticFeedback,
      scrollHapticType: scrollHapticType ?? this.scrollHapticType,
      selectionHapticType: selectionHapticType ?? this.selectionHapticType,
      usePlatformStyling: usePlatformStyling ?? this.usePlatformStyling,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
