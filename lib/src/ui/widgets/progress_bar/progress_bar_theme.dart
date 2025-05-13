import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';

/// Theme extension for segmented progress bar
///
/// This class provides theming capabilities for the segmented progress bar component,
/// allowing customization of colors, sizes, and other visual properties.
class ProgressBarTheme extends ThemeExtension<ProgressBarTheme> {
  /// Color of completed segments
  final Color completedSegmentColor;

  /// Color of incomplete segments
  final Color incompleteSegmentColor;

  /// Color of the label text
  final Color labelColor;

  /// Width of each segment
  final double segmentWidth;

  /// Height of each segment
  final double segmentHeight;

  /// Spacing between segments
  final double segmentSpacing;

  /// Border radius of segments
  final BorderRadius segmentBorderRadius;

  /// Whether to show the pulsing effect on the last completed segment
  final bool showPulsingEffect;

  /// Duration of the pulsing animation
  final Duration pulsingDuration;

  /// Creates a progress bar theme
  const ProgressBarTheme({
    required this.completedSegmentColor,
    required this.incompleteSegmentColor,
    required this.labelColor,
    required this.segmentWidth,
    required this.segmentHeight,
    required this.segmentSpacing,
    required this.segmentBorderRadius,
    this.showPulsingEffect = true,
    this.pulsingDuration = const Duration(milliseconds: 1500),
  });

  /// Creates a light theme for the progress bar
  factory ProgressBarTheme.light(BuildContext context) {
    return const ProgressBarTheme(
      completedSegmentColor: AppColor.primaryColor,
      incompleteSegmentColor: AppColor.backgroundColor,
      labelColor: Colors.black87,
      segmentWidth: 12,
      segmentHeight: 12,
      segmentSpacing: 8,
      segmentBorderRadius: BorderRadius.all(Radius.circular(6)),
    );
  }

  /// Creates a dark theme for the progress bar
  factory ProgressBarTheme.dark(BuildContext context) {
    return const ProgressBarTheme(
      completedSegmentColor: AppColor.secondaryColor,
      incompleteSegmentColor: AppColor.fourColor,
      labelColor: Colors.white70,
      segmentWidth: 12,
      segmentHeight: 12,
      segmentSpacing: 8,
      segmentBorderRadius: BorderRadius.all(Radius.circular(6)),
    );
  }

  /// Creates a theme for the progress bar based on the current theme brightness
  factory ProgressBarTheme.fromContext(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? ProgressBarTheme.light(context)
        : ProgressBarTheme.dark(context);
  }

  @override
  ProgressBarTheme copyWith({
    Color? completedSegmentColor,
    Color? incompleteSegmentColor,
    Color? labelColor,
    double? segmentWidth,
    double? segmentHeight,
    double? segmentSpacing,
    BorderRadius? segmentBorderRadius,
    bool? showPulsingEffect,
    Duration? pulsingDuration,
  }) {
    return ProgressBarTheme(
      completedSegmentColor:
          completedSegmentColor ?? this.completedSegmentColor,
      incompleteSegmentColor:
          incompleteSegmentColor ?? this.incompleteSegmentColor,
      labelColor: labelColor ?? this.labelColor,
      segmentWidth: segmentWidth ?? this.segmentWidth,
      segmentHeight: segmentHeight ?? this.segmentHeight,
      segmentSpacing: segmentSpacing ?? this.segmentSpacing,
      segmentBorderRadius: segmentBorderRadius ?? this.segmentBorderRadius,
      showPulsingEffect: showPulsingEffect ?? this.showPulsingEffect,
      pulsingDuration: pulsingDuration ?? this.pulsingDuration,
    );
  }

  @override
  ProgressBarTheme lerp(ThemeExtension<ProgressBarTheme>? other, double t) {
    if (other is! ProgressBarTheme) {
      return this;
    }

    return ProgressBarTheme(
      completedSegmentColor:
          Color.lerp(completedSegmentColor, other.completedSegmentColor, t)!,
      incompleteSegmentColor:
          Color.lerp(incompleteSegmentColor, other.incompleteSegmentColor, t)!,
      labelColor: Color.lerp(labelColor, other.labelColor, t)!,
      segmentWidth: lerpDouble(segmentWidth, other.segmentWidth, t)!,
      segmentHeight: lerpDouble(segmentHeight, other.segmentHeight, t)!,
      segmentSpacing: lerpDouble(segmentSpacing, other.segmentSpacing, t)!,
      segmentBorderRadius:
          BorderRadius.lerp(segmentBorderRadius, other.segmentBorderRadius, t)!,
      showPulsingEffect: t < 0.5 ? showPulsingEffect : other.showPulsingEffect,
      pulsingDuration: t < 0.5 ? pulsingDuration : other.pulsingDuration,
    );
  }

  /// Helper method to lerp double values
  static double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
