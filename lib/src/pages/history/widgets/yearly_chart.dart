import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/pages/history/water_history_view_model.dart';

/// Tab biểu đồ năm
class YearlyChartTab extends StatelessWidget {
  /// View model
  final WaterHistoryState viewModel;

  /// Callback khi thay đổi năm
  final Function(int) onYearChanged;

  /// Constructor
  const YearlyChartTab({
    super.key,
    required this.viewModel,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year selector
          _buildYearSelector(context),
          const SizedBox(height: 24),

          // Chart
          Expanded(
            child: viewModel.yearlyHistory.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.yearlyHistory.hasError
                    ? Center(child: Text('Error: ${viewModel.yearlyHistory.error}'))
                    : viewModel.yearlyHistory.value?.isNotEmpty == true
                        ? _buildYearlyChart(context, viewModel.yearlyHistory.value!)
                        : const Center(child: Text('No data for this year')),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    final year = viewModel.selectedYear;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            onYearChanged(year - 1);
          },
        ),
        TextButton(
          onPressed: () async {
            // Show year picker
            final selectedYear = await showDialog<int>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Year'),
                  content: SizedBox(
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      selectedDate: DateTime(year),
                      onChanged: (DateTime dateTime) {
                        Navigator.pop(context, dateTime.year);
                      },
                    ),
                  ),
                );
              },
            );

            if (selectedYear != null) {
              onYearChanged(selectedYear);
            }
          },
          child: Text(
            year.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: year < DateTime.now().year
              ? () {
                  onYearChanged(year + 1);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildYearlyChart(BuildContext context, List<dynamic> histories) {
    // Tạo danh sách các điểm cho biểu đồ
    final spots = <FlSpot>[];

    for (int month = 1; month <= 12; month++) {
      double totalAmount = 0;

      // Tìm lịch sử cho tháng này
      for (final history in histories) {
        final historyDate = history.date;
        if (historyDate.year == viewModel.selectedYear && historyDate.month == month) {
          totalAmount += history.totalAmount;
        }
      }

      spots.add(FlSpot(month.toDouble(), totalAmount));
    }

    // Tính tổng lượng nước uống trong năm
    double totalYearlyIntake = 0;

    for (final history in histories) {
      totalYearlyIntake += history.totalAmount;
    }

    // Tính trung bình mỗi tháng
    final averageMonthlyIntake = totalYearlyIntake / 12;

    return Column(
      children: [
        // Thông tin tổng hợp
        _buildSummaryInfo(totalYearlyIntake, averageMonthlyIntake),
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
                    final month = group.x.toInt();
                    final amount = rod.toY.toInt();
                    final monthName = DateTimeUtils.getMonthName(month, short: true);
                    return BarTooltipItem(
                      '$monthName: $amount ml',
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
                      final month = value.toInt();
                      final monthName = DateTimeUtils.getMonthName(month, short: true);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(monthName),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10000,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${(value / 1000).toInt()}k',
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
                horizontalInterval: 10000,
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

  Widget _buildSummaryInfo(double totalIntake, double averageMonthlyIntake) {
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
                  'Total yearly intake:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${totalIntake.toInt()} ml',
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
                  'Average monthly:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${averageMonthlyIntake.toInt()} ml',
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
                  'Average daily:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${(averageMonthlyIntake / 30).toInt()} ml',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
