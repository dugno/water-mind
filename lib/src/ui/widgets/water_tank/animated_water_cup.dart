import 'dart:math';

import 'package:flutter/material.dart';
import 'water_cup.dart';

/// Widget hiển thị ly nước với hiệu ứng animation khi mực nước thay đổi
class AnimatedWaterCup extends StatefulWidget {
  /// Mực nước hiện tại (0.0 đến 1.0)
  final double waterLevel;

  /// Mức độ phát triển của cây (0.0 đến 1.0)
  final double plantGrowth;

  /// Pha sóng cho hiệu ứng sóng
  final double wavePhase;

  /// Mục tiêu uống nước hàng ngày (ml)
  final double dailyGoal;

  /// Khoảng cách giữa các vạch lớn (ml)
  final double majorTickInterval;

  /// Khoảng cách giữa các vạch nhỏ (ml)
  final double minorTickInterval;

  /// Chiều rộng của ly nước
  final double width;

  /// Chiều cao của ly nước
  final double height;

  /// Mực nước trước đó, dùng để xác định hướng animation
  final double? previousWaterLevel;

  /// Constructor
  const AnimatedWaterCup({
    super.key,
    required this.waterLevel,
    required this.plantGrowth,
    required this.wavePhase,
    required this.dailyGoal,
    required this.majorTickInterval,
    required this.minorTickInterval,
    this.width = 200,
    this.height = 300,
    this.previousWaterLevel,
  });

  @override
  State<AnimatedWaterCup> createState() => _AnimatedWaterCupState();
}

class _AnimatedWaterCupState extends State<AnimatedWaterCup> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waterLevelAnimation;
  late Animation<double> _plantGrowthAnimation;

  // Mực nước hiện tại trong animation
  double _currentWaterLevel = 0.0;

  // Mức độ phát triển của cây hiện tại trong animation
  double _currentPlantGrowth = 0.0;

  @override
  void initState() {
    super.initState();
    _currentWaterLevel = widget.waterLevel;
    _currentPlantGrowth = widget.plantGrowth;

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Khởi tạo animation cho mực nước
    _waterLevelAnimation = Tween<double>(
      begin: _currentWaterLevel,
      end: widget.waterLevel,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Khởi tạo animation cho cây
    _plantGrowthAnimation = Tween<double>(
      begin: _currentPlantGrowth,
      end: widget.plantGrowth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Lắng nghe sự thay đổi của animation
    _animationController.addListener(_updateAnimation);

    // Kiểm tra xem có cần chạy animation không
    if (widget.previousWaterLevel != null && widget.previousWaterLevel != widget.waterLevel) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(AnimatedWaterCup oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Kiểm tra xem mực nước có thay đổi không
    if (oldWidget.waterLevel != widget.waterLevel) {
      // Cập nhật animation
      _waterLevelAnimation = Tween<double>(
        begin: _currentWaterLevel,
        end: widget.waterLevel,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _plantGrowthAnimation = Tween<double>(
        begin: _currentPlantGrowth,
        end: widget.plantGrowth,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      // Chạy animation
      _animationController.forward(from: 0.0);
    }
  }

  void _updateAnimation() {
    setState(() {
      _currentWaterLevel = _waterLevelAnimation.value;
      _currentPlantGrowth = _plantGrowthAnimation.value;
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateAnimation);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: WaterCupPainter(
          waterLevel: _currentWaterLevel,
          plantGrowth: _currentPlantGrowth,
          wavePhase: widget.wavePhase,
          dailyGoal: widget.dailyGoal,
          majorTickInterval: widget.majorTickInterval,
          minorTickInterval: widget.minorTickInterval,
        ),
      ),
    );
  }
}
