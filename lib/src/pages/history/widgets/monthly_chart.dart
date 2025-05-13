import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/pages/history/water_history_view_model.dart';

/// Tab biểu đồ tháng
class MonthlyChartTab extends StatelessWidget {
  /// View model
  final WaterHistoryState viewModel;

  /// Callback khi thay đổi tháng
  final Function(DateTime) onMonthChanged;

  /// Constructor
  const MonthlyChartTab({
    super.key,
    required this.viewModel,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month selector
          _buildMonthSelector(context),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: viewModel.monthlyHistory.hasError
                ? Center(child: Text(
                    'Error: ${viewModel.monthlyHistory.error}',
                    style: const TextStyle(color: Colors.white),
                  ))
                : viewModel.monthlyHistory.value?.isNotEmpty == true
                    ? _buildMonthlyChart(context, viewModel.monthlyHistory.value!)
                    : const Center(child: Text(
                        'No data for this month',
                        style: TextStyle(color: Colors.white),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final month = viewModel.selectedMonth;
    final monthName = DateTimeUtils.getMonthName(month.month);
    final year = month.year;

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
              final previousMonth = DateTime(
                month.year,
                month.month - 1,
                1,
              );
              onMonthChanged(previousMonth);
            },
          ),
          TextButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: month,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                final newMonth = DateTime(selectedDate.year, selectedDate.month, 1);
                onMonthChanged(newMonth);
              }
            },
            child: Text(
              '$monthName $year',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: month.isBefore(DateTime(DateTime.now().year, DateTime.now().month, 1))
                ? () {
                    final nextMonth = DateTime(
                      month.year,
                      month.month + 1,
                      1,
                    );
                    if (nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                      onMonthChanged(nextMonth);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, List<dynamic> histories) {
    // Tạo danh sách các điểm cho biểu đồ
    final spots = <FlSpot>[];
    final daysInMonth = DateTimeUtils.getDaysInMonth(
      viewModel.selectedMonth.year,
      viewModel.selectedMonth.month,
    );

    for (int day = 1; day <= daysInMonth; day++) {
      double totalAmount = 0;

      // Tìm lịch sử cho ngày này
      final date = DateTime(viewModel.selectedMonth.year, viewModel.selectedMonth.month, day);
      for (final history in histories) {
        if (DateTimeUtils.isSameDay(history.date, date)) {
          totalAmount = history.totalAmount;
          break;
        }
      }

      spots.add(FlSpot(day.toDouble(), totalAmount));
    }

    // Tính tổng lượng nước uống trong tháng
    double totalMonthlyIntake = 0;
    double totalMonthlyGoal = 0;

    for (final history in histories) {
      totalMonthlyIntake += history.totalAmount;
      totalMonthlyGoal += history.dailyGoal;
    }

    return Column(
      children: [
        // Thông tin tổng hợp
        _buildSummaryInfo(totalMonthlyIntake, totalMonthlyGoal),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 500,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 0.8,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    // Highlight weekends
                    final day = value.toInt();
                    final date = DateTime(
                      viewModel.selectedMonth.year,
                      viewModel.selectedMonth.month,
                      day,
                    );
                    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

                    return FlLine(
                      color: isWeekend
                          ? Colors.red.withOpacity(0.1)
                          : Colors.white.withOpacity(0.1),
                      strokeWidth: 0.8,
                    );
                  },
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
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (day % 5 == 0 || day == 1) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              day.toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
                minX: 1,
                maxX: DateTimeUtils.getDaysInMonth(
                  viewModel.selectedMonth.year,
                  viewModel.selectedMonth.month,
                ).toDouble(),
                minY: 0,
                maxY: _getMaxY(spots),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    gradient: LinearGradient(
                      colors: [
                        AppColor.fourColor.withOpacity(0.7),
                        AppColor.thirdColor,
                        AppColor.secondaryColor,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // Nếu không có dữ liệu (y = 0), không hiển thị điểm
                        if (spot.y == 0) {
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        }

                        // Kiểm tra xem có phải là ngày cuối tuần không
                        final day = spot.x.toInt();
                        final date = DateTime(
                          viewModel.selectedMonth.year,
                          viewModel.selectedMonth.month,
                          day,
                        );
                        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

                        return FlDotCirclePainter(
                          radius: 5,
                          color: isWeekend ? AppColor.warningColor : AppColor.thirdColor,
                          strokeWidth: 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColor.secondaryColor.withOpacity(0.4),
                          AppColor.thirdColor.withOpacity(0.2),
                          AppColor.fourColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    shadow: const Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColor.primaryColor.withOpacity(0.85),
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final day = touchedSpot.x.toInt();
                        final amount = touchedSpot.y.toInt();
                        final date = DateTime(
                          viewModel.selectedMonth.year,
                          viewModel.selectedMonth.month,
                          day,
                        );
                        final dayOfWeek = DateTimeUtils.getDayOfWeekName(date.weekday, short: false);

                        return LineTooltipItem(
                          '$dayOfWeek, ${DateTimeUtils.formatDate(date)}',
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
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    // Thêm hiệu ứng khi chạm vào biểu đồ nếu cần
                  },
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.white,
                          strokeWidth: 2,
                          dashArray: [3, 3],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: AppColor.thirdColor,
                              strokeWidth: 3,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryInfo(double totalIntake, double totalGoal) {
    final progressPercentage = totalGoal > 0 ? (totalIntake / totalGoal).clamp(0.0, 1.0) : 0.0;
    final goalMet = totalIntake >= totalGoal;
    final progressColor = goalMet ? AppColor.successColor : AppColor.thirdColor;

    // Tính trung bình mỗi ngày
    final daysInMonth = DateTimeUtils.getDaysInMonth(
      viewModel.selectedMonth.year,
      viewModel.selectedMonth.month,
    );
    final averageDailyIntake = totalIntake / daysInMonth;

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
                      'Total monthly intake:',
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

          // Mục tiêu tháng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly goal:',
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
                width: 300 * progressPercentage, // Fixed width * percentage
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
                '${(progressPercentage * 100).toStringAsFixed(1)}% of monthly goal',
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
}
