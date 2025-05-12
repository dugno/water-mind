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
            child: viewModel.monthlyHistory.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : viewModel.monthlyHistory.hasError
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 500,
                verticalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
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
                          child: Text(day.toString()),
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
                            fontSize: 10,
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
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.blue,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(
                    show: true,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.blue.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final day = touchedSpot.x.toInt();
                      final amount = touchedSpot.y.toInt();
                      return LineTooltipItem(
                        'Day $day: $amount ml',
                        const TextStyle(color: Colors.white),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.thirdColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total monthly intake:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                '${totalIntake.toInt()} ml',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly goal:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                '${totalGoal.toInt()} ml',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              goalMet ? Colors.green : Colors.white,
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progressPercentage * 100).toStringAsFixed(1)}% of monthly goal',
            style: TextStyle(
              color: goalMet ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
