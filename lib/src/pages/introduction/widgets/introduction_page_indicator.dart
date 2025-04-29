import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';

/// A widget that displays dots to indicate the current page in a PageView
class IntroductionPageIndicator extends StatelessWidget {
  /// The total number of pages
  final int pageCount;
  
  /// The index of the current page
  final int currentPage;
  
  /// The size of the dots
  final double dotSize;
  
  /// The spacing between dots
  final double spacing;
  
  /// The color of the active dot
  final Color activeColor;
  
  /// The color of the inactive dots
  final Color inactiveColor;

  /// Creates a new [IntroductionPageIndicator] instance
  const IntroductionPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.dotSize = 10.0,
    this.spacing = 8.0,
    this.activeColor = AppColor.primaryColor,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}
