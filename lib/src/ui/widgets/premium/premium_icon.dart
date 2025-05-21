import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';

/// A widget that displays a premium icon
class PremiumIcon extends StatelessWidget {
  /// The size of the icon
  final double size;
  
  /// The color of the icon
  final Color? color;
  
  /// Whether to show a background
  final bool showBackground;
  
  /// The background color
  final Color? backgroundColor;
  
  /// Constructor
  const PremiumIcon({
    super.key,
    this.size = 16.0,
    this.color,
    this.showBackground = true,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColor.primaryColor;
    
    Widget icon = Icon(
      Icons.workspace_premium,
      size: size,
      color: iconColor,
    );
    
    if (showBackground) {
      return Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColor.fourColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: icon,
      );
    }
    
    return icon;
  }
}

/// A widget that displays a premium badge on top of another widget
class PremiumBadge extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// The position of the badge
  final AlignmentGeometry alignment;
  
  /// The size of the badge
  final double badgeSize;
  
  /// Constructor
  const PremiumBadge({
    super.key,
    required this.child,
    this.alignment = Alignment.topRight,
    this.badgeSize = 16.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: PremiumIcon(
            size: badgeSize,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }
}
