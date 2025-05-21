import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';

/// A base bottom sheet widget that can be extended for various use cases
class BaseBottomSheet extends StatelessWidget {
  /// The content of the bottom sheet
  final Widget child;

  /// Whether to show a drag handle at the top
  final bool showDragHandle;

  /// Whether the bottom sheet is scrollable
  final bool isScrollable;

  /// The padding around the content
  final EdgeInsets padding;

  /// The background color of the bottom sheet
  final Color? backgroundColor;

  /// Whether to use gradient background
  final bool useGradientBackground;

  /// The shape of the bottom sheet
  final ShapeBorder? shape;

  /// The maximum height of the bottom sheet as a fraction of screen height
  final double? maxHeightFactor;

  /// Constructor
  const BaseBottomSheet({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.isScrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.backgroundColor,
    this.useGradientBackground = false,
    this.shape,
    this.maxHeightFactor,
  });

  /// Show the bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool showDragHandle = true,
    bool isScrollable = true,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    Color? backgroundColor,
    bool useGradientBackground = false,
    ShapeBorder? shape,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeightFactor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: useGradientBackground ? Colors.transparent : (backgroundColor ?? Colors.white),
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BaseBottomSheet(
        showDragHandle: showDragHandle,
        isScrollable: isScrollable,
        padding: padding,
        backgroundColor: backgroundColor,
        useGradientBackground: useGradientBackground,
        shape: shape,
        maxHeightFactor: maxHeightFactor,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = maxHeightFactor != null
        ? mediaQuery.size.height * maxHeightFactor!
        : null;

    Widget content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) _buildDragHandle(context),
          if (showDragHandle) const SizedBox(height: 8),
          Flexible(child: child),
          // Add padding to account for bottom insets (keyboard, etc.)
          SizedBox(height: mediaQuery.viewInsets.bottom),
        ],
      ),
    );

    if (isScrollable) {
      content = SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? mediaQuery.size.height * 0.9,
          ),
          child: content,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: useGradientBackground ? null : (backgroundColor ?? Theme.of(context).colorScheme.surface),
        gradient: useGradientBackground ? LinearGradient(
          colors: [
            AppColor.primaryColor.withAlpha(204), // 0.8 opacity
            AppColor.secondaryColor.withAlpha(179), // 0.7 opacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: useGradientBackground ? [
          BoxShadow(
            color: AppColor.primaryColor.withAlpha(77), // 0.3 opacity
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: SafeArea(
        child: content,
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: useGradientBackground
              ? Colors.white.withAlpha(51) // 0.2 opacity
              : Theme.of(context).colorScheme.onSurface.withAlpha(51), // 0.2 opacity
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
