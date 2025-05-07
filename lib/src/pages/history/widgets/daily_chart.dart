import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/pages/history/water_history_view_model.dart';

/// Tab biểu đồ ngày
class DailyChartTab extends StatelessWidget {
  /// View model
  final WaterHistoryState viewModel;

  /// Callback khi thay đổi ngày
  final Function(DateTime) onDateChanged;

  /// Constructor
  const DailyChartTab({
    super.key,
    required this.viewModel,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector
          _buildDateSelector(context),
          const SizedBox(height: 24),

          // Chart
          Expanded(
            child: viewModel.dailyHistory.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.dailyHistory.hasError
                    ? Center(child: Text('Error: ${viewModel.dailyHistory.error}'))
                    : _buildDailyChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            final previousDay = viewModel.selectedDate.subtract(const Duration(days: 1));
            onDateChanged(previousDay);
          },
        ),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: viewModel.selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onDateChanged(selectedDate);
            }
          },
          child: Text(
            DateTimeUtils.formatDate(viewModel.selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: viewModel.selectedDate.isBefore(DateTime.now())
              ? () {
                  final nextDay = viewModel.selectedDate.add(const Duration(days: 1));
                  if (nextDay.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                    onDateChanged(nextDay);
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDailyChart(BuildContext context) {
    final history = viewModel.dailyHistory.value;
    if (history == null) {
      return const Center(child: Text('No data available'));
    }

    // Tạo danh sách các điểm cho biểu đồ
    final spots = <FlSpot>[];
    for (int hour = 0; hour < 24; hour++) {
      double amount = 0;
      for (final entry in history.entries) {
        if (entry.timestamp.hour == hour) {
          amount += entry.amount;
        }
      }
      spots.add(FlSpot(hour.toDouble(), amount));
    }

    // Lấy danh sách thời gian nhắc nhở
    final reminderTimes = <TimeOfDay>[];

    // Tạo danh sách các vị trí đường dọc cho thời gian nhắc nhở
    final reminderSpots = reminderTimes.map((time) {
      final hour = time.hour.toDouble();
      final minute = time.minute / 60.0;
      return hour + minute;
    }).toList();

    return Column(
      children: [
        // Thông tin tổng hợp
        _buildSummaryInfo(history),
        const SizedBox(height: 16),

        // Biểu đồ
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 100,
                verticalInterval: 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  // Kiểm tra xem có phải là thời gian nhắc nhở không
                  if (reminderSpots.contains(value)) {
                    return FlLine(
                      color: Colors.red.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  }

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
                    interval: 4,
                    getTitlesWidget: (value, meta) {
                      final hour = value.toInt();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text('${hour}h'),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100,
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
              minX: 0,
              maxX: 23,
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
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      // Kiểm tra xem có phải là thời gian nhắc nhở không
                      bool isReminderTime = false;
                      for (final time in reminderTimes) {
                        final hour = time.hour.toDouble();
                        final minute = time.minute / 60.0;
                        if ((spot.x - (hour + minute)).abs() < 0.1) {
                          isReminderTime = true;
                          break;
                        }
                      }

                      return FlDotCirclePainter(
                        radius: 4,
                        color: isReminderTime ? Colors.red : Colors.blue,
                        strokeWidth: 2,
                        strokeColor: isReminderTime ? Colors.red.withOpacity(0.5) : Colors.white,
                      );
                    },
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
                      final hour = touchedSpot.x.toInt();
                      final amount = touchedSpot.y.toInt();

                      // Kiểm tra xem có phải là thời gian nhắc nhở không
                      bool isReminderTime = false;
                      for (final time in reminderTimes) {
                        if (time.hour == hour) {
                          isReminderTime = true;
                          break;
                        }
                      }

                      return LineTooltipItem(
                        isReminderTime
                            ? '$hour:00 - $amount ml\nReminder time!'
                            : '$hour:00 - $amount ml',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),

        // Chú thích
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Water intake'),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Reminder time'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryInfo(WaterIntakeHistory? history) {
    if (history == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total intake:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  history.formattedTotalAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily goal:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  history.formattedDailyGoal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: history.progressPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                history.goalMet ? Colors.green : Colors.blue,
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 4),
            Text(
              '${(history.progressPercentage * 100).toStringAsFixed(1)}% of daily goal',
              style: TextStyle(
                color: history.goalMet ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

    // Làm tròn lên đến 100 gần nhất và thêm 100 để có khoảng trống
    return ((maxY / 100).ceil() * 100 + 100).toDouble();
  }
}
