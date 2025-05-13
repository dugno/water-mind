import 'package:flutter/material.dart';

/// Widget hiển thị cốc nước đơn giản với lượng nước hiện tại và lượng nước tối đa
class SimpleWaterCup extends StatelessWidget {
  /// Lượng nước hiện tại (ml)
  final double currentWaterAmount;

  /// Lượng nước tối đa (ml)
  final double maxWaterAmount;

  /// Chiều rộng của cốc nước
  final double width;

  /// Chiều cao của cốc nước
  final double height;

  /// Constructor
  const SimpleWaterCup({
    super.key,
    required this.currentWaterAmount,
    this.maxWaterAmount = 1000,
    this.width = 200,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    // Đảm bảo lượng nước hiện tại không vượt quá lượng nước tối đa
    final safeCurrentAmount = currentWaterAmount.clamp(0, maxWaterAmount);
    
    // Tính toán tỷ lệ lượng nước hiện tại so với lượng nước tối đa
    final waterLevel = safeCurrentAmount / maxWaterAmount;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Vẽ cốc nước
          CustomPaint(
            size: Size(width, height),
            painter: SimpleWaterCupPainter(
              waterLevel: waterLevel,
              currentWaterAmount: safeCurrentAmount.toDouble(),
              maxWaterAmount: maxWaterAmount,
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter để vẽ cốc nước
class SimpleWaterCupPainter extends CustomPainter {
  /// Tỷ lệ mực nước (0.0 đến 1.0)
  final double waterLevel;
  
  /// Lượng nước hiện tại (ml)
  final double currentWaterAmount;
  
  /// Lượng nước tối đa (ml)
  final double maxWaterAmount;

  /// Constructor
  SimpleWaterCupPainter({
    required this.waterLevel,
    required this.currentWaterAmount,
    required this.maxWaterAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ cốc nước
    _drawCup(canvas, size);
    
    // Vẽ mực nước
    _drawWater(canvas, size);
  }

  /// Vẽ cốc nước
  void _drawCup(Canvas canvas, Size size) {
    // Định nghĩa paint cho cốc nước
    final cupPaint = Paint()
      ..color = Colors.blue[50]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final cupBorderPaint = Paint()
      ..color = Colors.blue[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Tính toán kích thước cốc
    final cupWidth = size.width * 0.8;
    final cupHeight = size.height * 0.9;
    final cupLeft = (size.width - cupWidth) / 2;
    final cupTop = (size.height - cupHeight) / 2;
    
    // Vẽ hình dạng cốc (hình chữ nhật với góc bo tròn ở đáy)
    final cupPath = Path()
      ..moveTo(cupLeft, cupTop)
      ..lineTo(cupLeft, cupTop + cupHeight - 10)
      ..quadraticBezierTo(
        cupLeft, cupTop + cupHeight,
        cupLeft + 10, cupTop + cupHeight,
      )
      ..lineTo(cupLeft + cupWidth - 10, cupTop + cupHeight)
      ..quadraticBezierTo(
        cupLeft + cupWidth, cupTop + cupHeight,
        cupLeft + cupWidth, cupTop + cupHeight - 10,
      )
      ..lineTo(cupLeft + cupWidth, cupTop)
      ..close();
    
    // Vẽ cốc
    canvas.drawPath(cupPath, cupPaint);
    canvas.drawPath(cupPath, cupBorderPaint);
  }

  /// Vẽ mực nước
  void _drawWater(Canvas canvas, Size size) {
    // Chỉ vẽ nước nếu có lượng nước
    if (waterLevel <= 0) return;
    
    // Định nghĩa paint cho nước
    final waterPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue[300]!, Colors.blue[600]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Tính toán kích thước cốc
    final cupWidth = size.width * 0.8;
    final cupHeight = size.height * 0.9;
    final cupLeft = (size.width - cupWidth) / 2;
    final cupTop = (size.height - cupHeight) / 2;
    
    // Tính toán chiều cao của nước
    final waterHeight = cupHeight * waterLevel;
    final waterTop = cupTop + cupHeight - waterHeight;
    
    // Vẽ hình dạng nước
    final waterPath = Path();
    
    if (waterHeight >= 10) {
      // Nếu nước cao hơn phần bo tròn ở đáy
      waterPath.moveTo(cupLeft, waterTop);
      waterPath.lineTo(cupLeft, cupTop + cupHeight - 10);
      waterPath.quadraticBezierTo(
        cupLeft, cupTop + cupHeight,
        cupLeft + 10, cupTop + cupHeight,
      );
      waterPath.lineTo(cupLeft + cupWidth - 10, cupTop + cupHeight);
      waterPath.quadraticBezierTo(
        cupLeft + cupWidth, cupTop + cupHeight,
        cupLeft + cupWidth, cupTop + cupHeight - 10,
      );
      waterPath.lineTo(cupLeft + cupWidth, waterTop);
      waterPath.close();
    } else {
      // Nếu nước chỉ ở phần bo tròn ở đáy
      final ratio = waterHeight / 10;
      final bottomWidth = cupWidth - (1 - ratio) * 20;
      
      waterPath.moveTo(cupLeft + (cupWidth - bottomWidth) / 2, waterTop);
      waterPath.lineTo(cupLeft + 10, cupTop + cupHeight - 10 + 10 * (1 - ratio));
      waterPath.quadraticBezierTo(
        cupLeft + 10 * ratio, cupTop + cupHeight - 10 * (1 - ratio),
        cupLeft + 10 + 10 * (1 - ratio), cupTop + cupHeight,
      );
      waterPath.lineTo(cupLeft + cupWidth - 10 - 10 * (1 - ratio), cupTop + cupHeight);
      waterPath.quadraticBezierTo(
        cupLeft + cupWidth - 10 * ratio, cupTop + cupHeight - 10 * (1 - ratio),
        cupLeft + cupWidth - 10, cupTop + cupHeight - 10 + 10 * (1 - ratio),
      );
      waterPath.lineTo(cupLeft + cupWidth - (cupWidth - bottomWidth) / 2, waterTop);
      waterPath.close();
    }
    
    // Vẽ nước
    canvas.drawPath(waterPath, waterPaint);
  }
  @override
  bool shouldRepaint(covariant SimpleWaterCupPainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.currentWaterAmount != currentWaterAmount ||
        oldDelegate.maxWaterAmount != maxWaterAmount;
  }
}
