import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that represents a single page in the introduction screen
class IntroductionPageItem extends ConsumerWidget {
  /// The title of the page
  final String title;
  /// The description of the page
  final String description;
  /// The image to display on the page
  final Widget? image;
  /// The color of the page background
  final Color? backgroundColor;

  /// Creates a new [IntroductionPageItem] instance
  const IntroductionPageItem({
    super.key,
    required this.title,
    required this.description,
    this.image,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) ...[
            Expanded(
              flex: 3,
              child: Center(child: image!),
            ),
            const SizedBox(height: 32.0),
          ],
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
