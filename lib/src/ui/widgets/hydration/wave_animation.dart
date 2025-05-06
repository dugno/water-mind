import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that displays a wave animation
class WaveAnimation extends StatefulWidget {
  /// The color of the wave
  final Color color;

  /// The duration of the animation
  final Duration animationDuration;

  /// Constructor
  const WaveAnimation({
    super.key,
    required this.color,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animation: _controller,
            color: widget.color,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// Custom painter for the wave animation
class WavePainter extends CustomPainter {
  /// The animation controller
  final Animation<double> animation;

  /// The color of the wave
  final Color color;

  /// Constructor
  WavePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height * 0.5;
    final amplitude = height * 0.1; // Wave height
    const frequency = 2.0; // Number of waves

    // Start at the left bottom corner
    path.moveTo(0, centerY);

    // Draw the wave
    for (var x = 0.0; x <= width; x++) {
      final y = centerY +
          amplitude *
              math.sin((x / width * frequency * math.pi * 2) +
                  (animation.value * math.pi * 2));
      path.lineTo(x, y);
    }

    // Complete the path
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    // Draw the wave
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
