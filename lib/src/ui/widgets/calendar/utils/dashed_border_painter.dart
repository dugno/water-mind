import 'package:flutter/material.dart';

/// Custom painter để vẽ đường viền đứt nét (dashed border)
class DashedBorderPainter extends CustomPainter {
  /// Màu của đường viền
  final Color color;

  /// Độ rộng của đường viền
  final double strokeWidth;

  /// Độ dài của mỗi đoạn nét
  final double dashLength;

  /// Độ dài của khoảng trống giữa các đoạn nét
  final double gapLength;

  /// Constructor
  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Tính toán chu vi của hình tròn
    final double radius = size.width / 2;
    final double circumference = 2 * 3.14159 * radius;

    // Tính toán số lượng đoạn nét và khoảng trống
    final double dashGapSum = dashLength + gapLength;
    final int dashCount = (circumference / dashGapSum).floor();

    // Vẽ đường viền đứt nét theo hình tròn
    for (int i = 0; i < dashCount; i++) {
      // Tính toán góc bắt đầu và kết thúc cho mỗi đoạn nét
      final double startAngle = i * dashGapSum / radius;
      final double endAngle = startAngle + dashLength / radius;

      // Vẽ đoạn nét
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
