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
            child: viewModel.weeklyHistory.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : viewModel.weeklyHistory.hasError
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
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = group.x.toInt();
                    final amount = rod.toY.toInt();
                    final dayName = DateTimeUtils.getDayOfWeekName(day + 1, short: true);
                    return BarTooltipItem(
                      '$dayName: $amount ml',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
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
                        child: Text(dayName),
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
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: _getBarGroups(spots),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups(List<FlSpot> spots) {
    return spots.map((spot) {
      return BarChartGroupData(
        x: spot.x.toInt(),
        barRods: [
          BarChartRodData(
            toY: spot.y,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.8),
                Colors.blue,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
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
                'Total weekly intake:',
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
                'Weekly goal:',
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
            '${(progressPercentage * 100).toStringAsFixed(1)}% of weekly goal',
            style: TextStyle(
              color: goalMet ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
