import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: App(),
    ),
  );
}





class WaterTankScreen extends StatefulWidget {
  @override
  _WaterTankScreenState createState() => _WaterTankScreenState();
}

class _WaterTankScreenState extends State<WaterTankScreen>
    with TickerProviderStateMixin {
  double _waterIntake = 750; // Current water intake in ml
  double _dailyGoal = 2000; // Configurable daily goal in ml
  late AnimationController _waveController; // For continuous wave animation
  late AnimationController _levelController; // For water level transitions
  late Animation<double> _waterLevelAnimation;
  late Animation<double> _waveAnimation;

  // Ruler parameters
  final double _majorTickInterval = 500; // Major ticks every 500ml
  final double _minorTickInterval = 100; // Minor ticks every 100ml

  @override
  void initState() {
    super.initState();
    // Wave animation (runs indefinitely)
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });

    // Water level animation (for smooth transitions)
    _levelController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waterLevelAnimation = Tween<double>(
      begin: 0,
      end: _waterIntake / _dailyGoal,
    ).animate(
        CurvedAnimation(parent: _levelController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
    _levelController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _addWater(double amount) {
    setState(() {
      _waterIntake = (_waterIntake + amount).clamp(0, _dailyGoal);
      _waterLevelAnimation = Tween<double>(
        begin: _waterLevelAnimation.value,
        end: _waterIntake / _dailyGoal,
      ).animate(
          CurvedAnimation(parent: _levelController, curve: Curves.easeInOut));
      _levelController.reset();
      _levelController.forward();
    });
  }

  void _updateDailyGoal(double newGoal) {
    setState(() {
      _dailyGoal = newGoal;
      _waterIntake = _waterIntake.clamp(0, _dailyGoal);
      _waterLevelAnimation = Tween<double>(
        begin: _waterLevelAnimation.value,
        end: _waterIntake / _dailyGoal,
      ).animate(
          CurvedAnimation(parent: _levelController, curve: Curves.easeInOut));
      _levelController.reset();
      _levelController.forward();
    });
  }

  String _getMotivationalMessage() {
    final percentage = (_waterIntake / _dailyGoal * 100).toInt();
    if (percentage < 30) return "Let's start hydrating!";
    if (percentage < 60) return "Keep nourishing your plant!";
    if (percentage < 90) return "You're doing great!";
    return "Your body is thriving!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_waterIntake.toInt()}ml / ${_dailyGoal.toInt()}ml',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 300,
              child: CustomPaint(
                painter: WaterCupPainter(
                  waterLevel: _waterLevelAnimation.value,
                  plantGrowth: _waterLevelAnimation.value,
                  wavePhase: _waveAnimation.value,
                  dailyGoal: _dailyGoal,
                  majorTickInterval: _majorTickInterval,
                  minorTickInterval: _minorTickInterval,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _getMotivationalMessage(),
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _addWater(250),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('+ Add 250ml',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _updateDailyGoal(1500),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Set Goal 1500ml',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _updateDailyGoal(2500),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Set Goal 2500ml',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaterCupPainter extends CustomPainter {
  final double waterLevel; // 0.0 to 1.0
  final double plantGrowth; // 0.0 to 1.0
  final double wavePhase; // For animating waves
  final double dailyGoal; // Total water volume in ml
  final double majorTickInterval; // Major tick interval in ml
  final double minorTickInterval; // Minor tick interval in ml

  WaterCupPainter({
    required this.waterLevel,
    required this.plantGrowth,
    required this.wavePhase,
    required this.dailyGoal,
    required this.majorTickInterval,
    required this.minorTickInterval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw crystal cup (narrow top, wide bottom)
    final cupPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyan[50]!.withOpacity(0.4),
          Colors.blue[100]!.withOpacity(0.3),
          Colors.white.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    final cupBorderPaint = Paint()
      ..color = Colors.cyan[200]!.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cupPath = Path()
      ..moveTo(20, 20) // Top left (narrow)
      ..lineTo(40, size.height - 20) // Bottom left (wider)
      ..quadraticBezierTo(40, size.height, 50, size.height) // Bottom curve left
      ..lineTo(size.width - 50, size.height) // Bottom right
      ..quadraticBezierTo(size.width - 40, size.height, size.width - 40,
          size.height - 20) // Bottom curve right
      ..lineTo(size.width - 20, 20) // Top right (narrow)
      ..quadraticBezierTo(
          size.width - 20, 0, size.width - 30, 0) // Top curve right
      ..lineTo(30, 0) // Top left
      ..quadraticBezierTo(20, 0, 20, 20); // Top curve left
    canvas.drawPath(cupPath, cupPaint);
    canvas.drawPath(cupPath, cupBorderPaint);

    // Draw faceted crystal effect (diagonal lines for cuts)
    final facetPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double y = 50; y < size.height - 50; y += 30) {
      canvas.drawLine(
        Offset(25, y),
        Offset(35, y + 20),
        facetPaint,
      );
      canvas.drawLine(
        Offset(size.width - 25, y),
        Offset(size.width - 35, y + 20),
        facetPaint,
      );
    }

    // Calculate water boundaries
    final waterHeight = (size.height - 40) * waterLevel;
    final y = size.height - 20 - waterHeight;
    final t = (y - 20) /
        (size.height - 40); // Normalized height (0 at top, 1 at bottom)
    final leftX = 20 + (40 - 20) * t; // Interpolate left edge
    final rightX = (size.width - 20) -
        ((size.width - 20) - (size.width - 40)) * t; // Interpolate right edge
    final waveWidth = rightX - leftX;

    // Draw water level ruler
    final rulerPaint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    // Main ruler line
    final rulerX = size.width - 10;
    canvas.drawLine(
      Offset(rulerX, 20),
      Offset(rulerX, size.height - 20),
      rulerPaint,
    );
    // Draw ticks and labels
    for (double level = 0; level <= dailyGoal; level += minorTickInterval) {
      final levelFraction = level / dailyGoal;
      final tickY = size.height - 20 - (size.height - 40) * levelFraction;
      final isMajorTick = level % majorTickInterval == 0;
      final tickLength = isMajorTick ? 8.0 : 4.0;
      // Draw tick
      canvas.drawLine(
        Offset(rulerX - tickLength, tickY),
        Offset(rulerX, tickY),
        rulerPaint,
      );
      // Draw label for major ticks
      if (isMajorTick) {
        textPainter.text = TextSpan(
          text: '${level.toInt()}ml',
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(rulerX + 2, tickY - 6));
      }
    }

    // Draw first wave layer (base water)
    final waterPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue[300]!, Colors.blue[600]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(
          20, size.height - 40 - waterHeight, size.width - 40, waterHeight));
    final waterPath = Path();
    waterPath.moveTo(40, size.height - 20); // Bottom left of cup
    waterPath.lineTo(leftX, y); // Water level left edge
    for (double x = leftX; x <= rightX; x += 1) {
      final normalizedX = (x - leftX) / waveWidth;
      final waveY = y + 10 * sin(normalizedX * 2 * pi + wavePhase);
      waterPath.lineTo(x, waveY);
    }
    waterPath.lineTo(rightX, y);
    waterPath.lineTo(size.width - 40, size.height - 20); // Bottom right
    waterPath.close();
    canvas.drawPath(waterPath, waterPaint);

    // Draw second wave layer (overlay for depth)
    final overlayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue[200]!.withOpacity(0.5),
          Colors.blue[400]!.withOpacity(0.5)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(
          20, size.height - 40 - waterHeight, size.width - 40, waterHeight));
    final overlayPath = Path();
    overlayPath.moveTo(40, size.height - 20);
    overlayPath.lineTo(leftX, y);
    for (double x = leftX; x <= rightX; x += 1) {
      final normalizedX = (x - leftX) / waveWidth;
      final waveY = y + 6 * sin(normalizedX * 3 * pi + wavePhase + pi / 2);
      overlayPath.lineTo(x, waveY);
    }
    overlayPath.lineTo(rightX, y);
    overlayPath.lineTo(size.width - 40, size.height - 20);
    overlayPath.close();
    canvas.drawPath(overlayPath, overlayPaint);

    // Draw bubbles (within water boundaries)
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final random = Random(0);
    for (int i = 0; i < 5; i++) {
      final x = leftX + random.nextDouble() * waveWidth;
      final bubbleY = size.height - 30 - random.nextDouble() * waterHeight;
      canvas.drawCircle(
          Offset(x, bubbleY), 3 + random.nextDouble() * 3, bubblePaint);
    }

    // Draw plant
    final plantPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.fill;
    final stemHeight = 50 * plantGrowth;
    final stemPath = Path()
      ..moveTo(size.width / 2, size.height - 20)
      ..lineTo(size.width / 2, size.height - 20 - stemHeight);
    canvas.drawPath(stemPath, plantPaint);
    final leafPaint = Paint()..color = Colors.green[600]!;
    canvas.drawCircle(
        Offset(size.width / 2 - 10, size.height - 20 - stemHeight),
        8 * plantGrowth,
        leafPaint);
    canvas.drawCircle(
        Offset(size.width / 2 + 10, size.height - 20 - stemHeight),
        8 * plantGrowth,
        leafPaint);
  }

  @override
  bool shouldRepaint(covariant WaterCupPainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.plantGrowth != plantGrowth ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.dailyGoal != dailyGoal ||
        oldDelegate.majorTickInterval != majorTickInterval ||
        oldDelegate.minorTickInterval != minorTickInterval;
  }
}
