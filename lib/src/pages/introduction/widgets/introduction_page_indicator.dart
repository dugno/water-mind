import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that displays dots to indicate the current page in a PageView
class IntroductionPageIndicator extends ConsumerWidget {
  /// The total number of pages
  final int pageCount;

  /// The index of the current page
  final int currentPage;

  /// The size of the dots
  final double? dotSize;

  /// The spacing between dots
  final double? spacing;

  /// The color of the active dot
  final Color? activeColor;

  /// The color of the inactive dots
  final Color? inactiveColor;

  /// Creates a new [IntroductionPageIndicator] instance
  const IntroductionPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.dotSize,
    this.spacing,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeDotColor = activeColor ?? colorScheme.primary;
    final inactiveDotColor =
        inactiveColor ?? colorScheme.onSurface.withOpacity(0.3);
    final dotSizeValue = dotSize ?? 10.0;
    final spacingValue = spacing ?? 8.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: spacingValue / 2),
          width: dotSizeValue,
          height: dotSizeValue,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage ? activeDotColor : inactiveDotColor,
          ),
        ),
      ),
    );
  }
}
