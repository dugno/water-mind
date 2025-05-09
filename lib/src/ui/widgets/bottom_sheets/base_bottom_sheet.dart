import 'package:flutter/material.dart';

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
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BaseBottomSheet(
        showDragHandle: showDragHandle,
        isScrollable: isScrollable,
        padding: padding,
        backgroundColor: backgroundColor,
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
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
