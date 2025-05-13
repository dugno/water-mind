import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/pages/history/water_history_view_model.dart';

/// Tab biểu đồ tuần
class WeeklyChartTab extends StatelessWidget {
  /// View model
  final WaterHistoryState viewModel;

  /// Callback khi thay đổi tuần
  final Function(DateTime) onWeekChanged;

  /// Constructor
  const WeeklyChartTab({
    super.key,
    required this.viewModel,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week selector
          _buildWeekSelector(context),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: viewModel.weeklyHistory.hasError
                ? Center(child: Text(
                    'Error: ${viewModel.weeklyHistory.error}',
                    style: const TextStyle(color: Colors.white),
                  ))
                : viewModel.weeklyHistory.value?.isNotEmpty == true
                    ? _buildWeeklyChart(context, viewModel.weeklyHistory.value!)
                    : const Center(child: Text(
                        'No data for this week',
                        style: TextStyle(color: Colors.white),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context) {
    final startOfWeek = viewModel.selectedWeek;
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Container(
      decoration: BoxDecoration(
        color: AppColor.thirdColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              final previousWeek = startOfWeek.subtract(const Duration(days: 7));
              onWeekChanged(previousWeek);
            },
          ),
          TextButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: startOfWeek,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                final newStartOfWeek = DateTimeUtils.getStartOfWeek(selectedDate);
                onWeekChanged(newStartOfWeek);
              }
            },
            child: Text(
              '${DateTimeUtils.formatDate(startOfWeek)} - ${DateTimeUtils.formatDate(endOfWeek)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: startOfWeek.isBefore(DateTimeUtils.getStartOfWeek(DateTime.now()))
                ? () {
                    final nextWeek = startOfWeek.add(const Duration(days: 7));
                    if (nextWeek.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                      onWeekChanged(nextWeek);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<dynamic> histories) {
    // Tạo danh sách các điểm cho biểu đồ
    final spots = <FlSpot>[];
    for (int day = 0; day < 7; day++) {
      double totalAmount = 0;

      // Tìm lịch sử cho ngày này
      final date = viewModel.selectedWeek.add(Duration(days: day));
      for (final history in histories) {
        if (DateTimeUtils.isSameDay(history.date, date)) {
          totalAmount = history.totalAmount;
          break;
        }
      }

      spots.add(FlSpot(day.toDouble(), totalAmount));
    }

    // Tính tổng lượng nước uống trong tuần
    double totalWeeklyIntake = 0;
    double totalWeeklyGoal = 0;

    for (final history in histories) {
      totalWeeklyIntake += history.totalAmount;
      totalWeeklyGoal += history.dailyGoal;
    }

    return Column(
      children: [
        // Thông tin tổng hợp
        _buildSummaryInfo(totalWeeklyIntake, totalWeeklyGoal),
        const SizedBox(height: 16),

        // Biểu đồ
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
             padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColor.primaryColor.withOpacity(0.85),
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = group.x.toInt();
                      final amount = rod.toY.toInt();
                      final dayName = DateTimeUtils.getDayOfWeekName(day + 1, short: false);
                      final date = viewModel.selectedWeek.add(Duration(days: day));
                      final formattedDate = DateTimeUtils.formatDate(date);

                      return BarTooltipItem(
                        '$dayName ($formattedDate)',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: '$amount ml',
                            style: TextStyle(
                              color: amount > 0 ? AppColor.fourColor : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
                    // Xử lý sự kiện chạm để cải thiện trải nghiệm người dùng
                    // Tooltip sẽ tự động ẩn sau khi người dùng nhấc tay lên
                  },
                  // Đảm bảo tooltip chỉ hiển thị khi chạm vào
                  handleBuiltInTouches: true,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        final dayName = DateTimeUtils.getDayOfWeekName(day + 1, short: true);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            dayName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 0.8,
                      dashArray: [5, 5],
                    );
                  },
                ),
                barGroups: _getBarGroups(spots),
                maxY: _getMaxY(spots),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups(List<FlSpot> spots) {
    // Tìm giá trị lớn nhất để tính toán màu sắc
    double maxValue = 0;
    for (final spot in spots) {
      if (spot.y > maxValue) {
        maxValue = spot.y;
      }
    }

    return spots.map((spot) {
      // Sử dụng màu đồng nhất cho tất cả các cột
      final colors = [
        AppColor.thirdColor,
        AppColor.thirdColor.withOpacity(0.7),
      ];

      return BarChartGroupData(
        x: spot.x.toInt(),
        barRods: [
          BarChartRodData(
            toY: spot.y,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 24, // Tăng độ rộng của cột
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(spots) * 0.9,
              color: Colors.white.withOpacity(0.08), // Tăng độ tương phản của nền
            ),
            rodStackItems: [
              // Thêm đường viền sáng ở trên cùng để tạo hiệu ứng 3D
              BarChartRodStackItem(
                spot.y - 5 > 0 ? spot.y - 5 : 0,
                spot.y,
                Colors.white.withOpacity(0.5), // Tăng độ sáng của viền
                BorderSide.none
              ),
            ],
            // Thêm viền để tạo hiệu ứng nổi bật
            borderSide: BorderSide(
              width: 1,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
        // Không hiển thị tooltip mặc định
        showingTooltipIndicators: [],
      );
    }).toList();
  }



  /// Tính toán giá trị Y tối đa cho biểu đồ
  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 500;

    double maxY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    // Làm tròn lên đến 500 gần nhất và thêm 500 để có khoảng trống
    return ((maxY / 500).ceil() * 500 + 500).toDouble();
  }

  Widget _buildSummaryInfo(double totalIntake, double totalGoal) {
    // Sử dụng giá trị cố định thay vì MediaQuery
    const progressBarWidth = 300.0;
    final progressPercentage = totalGoal > 0 ? (totalIntake / totalGoal).clamp(0.0, 1.0) : 0.0;
    final goalMet = totalIntake >= totalGoal;
    final progressColor = goalMet ? AppColor.successColor : AppColor.thirdColor;

    // Tính trung bình mỗi ngày
    final averageDailyIntake = totalIntake / 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.8),
            AppColor.secondaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Thông tin tổng hợp
          Row(
            children: [
              // Cột bên trái
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total weekly intake:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${totalIntake.toInt()} ml',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cột bên phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Average daily:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${averageDailyIntake.toInt()} ml',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mục tiêu tuần
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly goal:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${totalGoal.toInt()} ml',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Thanh tiến trình
          Stack(
            children: [
              // Background progress bar
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Actual progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 16,
                width: progressBarWidth * progressPercentage, // Fixed width * percentage
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor.withOpacity(0.7),
                      progressColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Thông tin tiến trình
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressPercentage * 100).toStringAsFixed(1)}% of weekly goal',
                style: TextStyle(
                  color: goalMet ? AppColor.successColor : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (goalMet)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.successColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Goal Achieved!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
