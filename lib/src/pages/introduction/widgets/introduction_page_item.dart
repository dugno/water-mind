import 'package:flutter/material.dart';

/// A widget that represents a single page in the introduction screen
class IntroductionPageItem extends StatelessWidget {
  /// The title of the page
  final String title;
  
  /// The description of the page
  final String description;
  
  /// The image to display on the page
  final Widget? image;
  
  /// The color of the page background
  final Color backgroundColor;

  /// Creates a new [IntroductionPageItem] instance
  const IntroductionPageItem({
    super.key,
    required this.title,
    required this.description,
    this.image,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
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
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
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
