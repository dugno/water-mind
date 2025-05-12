import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/history/water_history_view_model.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/water_intake_editor_sheet.dart';

/// Tab biểu đồ ngày
class DailyChartTab extends StatefulWidget {
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
  State<DailyChartTab> createState() => _DailyChartTabState();
}

class _DailyChartTabState extends State<DailyChartTab> {
  WaterHistoryState get viewModel => widget.viewModel;
  Function(DateTime) get onDateChanged => widget.onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector
          _buildDateSelector(context),
          const SizedBox(height: 16),

          // Chart and list in a scrollable container
          Expanded(
            child: viewModel.dailyHistory.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : viewModel.dailyHistory.hasError
                    ? Center(child: Text(
                        'Error: ${viewModel.dailyHistory.error}',
                        style: const TextStyle(color: Colors.white),
                      ))
                    : SingleChildScrollView(
                        child: _buildDailyChart(context),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
      ),
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 100,
                verticalInterval: 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withAlpha(77), // 0.3 opacity = 77 alpha
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  // Kiểm tra xem có phải là thời gian nhắc nhở không
                  if (reminderSpots.contains(value)) {
                    return FlLine(
                      color: Colors.red.withAlpha(128), // 0.5 opacity = 128 alpha
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  }

                  return FlLine(
                    color: Colors.grey.withAlpha(77), // 0.3 opacity = 77 alpha
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
                border: Border.all(color: Colors.grey.withAlpha(128)), // 0.5 opacity = 128 alpha
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
                      Colors.blue.withAlpha(204), // 0.8 opacity = 204 alpha
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
                        strokeColor: isReminderTime ? Colors.red.withAlpha(128) : Colors.white, // 0.5 opacity = 128 alpha
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withAlpha(77), // 0.3 opacity = 77 alpha
                        Colors.blue.withAlpha(26), // 0.1 opacity = 26 alpha
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueAccent.withAlpha(204), // 0.8 opacity = 204 alpha
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

        // Danh sách các lần uống nước
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.thirdColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'Water Intake Entries',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildWaterIntakeList(context, history),
            ],
          ),
        ),
        // Add some padding at the bottom for better scrolling experience
        const SizedBox(height: 16),
      ],
    );
  }

  /// Xây dựng danh sách các lần uống nước
  Widget _buildWaterIntakeList(BuildContext context, WaterIntakeHistory history) {
    if (history.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'No water intake entries for this day',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Sắp xếp entries theo thời gian (mới nhất lên đầu)
    final sortedEntries = List<WaterIntakeEntry>.from(history.entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEntries.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white24),
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return _buildWaterIntakeItem(context, entry, history.measureUnit);
      },
    );
  }

  /// Xây dựng một mục trong danh sách uống nước
  Widget _buildWaterIntakeItem(BuildContext context, WaterIntakeEntry entry, MeasureUnit measureUnit) {
    final timeFormat = DateFormat.Hm();
    final String unit = measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';

    return ListTile(
      leading: Icon(
        entry.drinkType.icon,
        color: entry.drinkType.color,
        size: 32,
      ),
      title: Text(
        '${entry.amount.toStringAsFixed(0)} $unit of ${entry.drinkType.name}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'at ${timeFormat.format(entry.timestamp)}${entry.note != null ? ' • ${entry.note}' : ''}',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () => _showEditEntryDialog(context, entry),
              tooltip: 'Edit entry',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () => _showDeleteConfirmation(context, entry),
              tooltip: 'Delete entry',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmation(BuildContext context, WaterIntakeEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.thirdColor,
        title: const Text('Delete Entry', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this water intake entry?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Call the delete method from view model
              final container = ProviderScope.containerOf(context);
              final notifier = container.read(waterHistoryViewModelProvider.notifier);
              notifier.deleteWaterIntakeEntry(entry);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị hộp thoại chỉnh sửa
  void _showEditEntryDialog(BuildContext context, WaterIntakeEntry entry) {
    // Show the water intake editor bottom sheet
    _showWaterAmountAndTimeEditor(context, entry);
  }

  /// Hiển thị bottom sheet chỉnh sửa thông tin uống nước
  Future<void> _showWaterAmountAndTimeEditor(
    BuildContext context,
    WaterIntakeEntry entry
  ) async {
    // Get the history to determine the measurement unit
    final history = viewModel.dailyHistory.value;
    if (history == null) return;

    // Lưu trữ notifier trước khi gọi async
    final notifier = ProviderScope.containerOf(context).read(waterHistoryViewModelProvider.notifier);

    final result = await WaterIntakeEditorSheet.show(
      context: context,
      initialAmount: entry.amount,
      initialTime: TimeOfDay.fromDateTime(entry.timestamp),
      initialDrinkType: entry.drinkType,
      initialNote: entry.note,
      measureUnit: history.measureUnit,
    );

    if (result != null && mounted) {
      // Tạo DateTime mới từ TimeOfDay
      final newDateTime = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
        result.time.hour,
        result.time.minute,
      );

      // Create updated entry
      final updatedEntry = WaterIntakeEntry(
        id: entry.id,
        timestamp: newDateTime,
        amount: result.amount,
        drinkType: result.drinkType,
        note: result.note,
      );

      // Call the edit method from view model
      notifier.updateWaterIntakeEntry(updatedEntry);
    }
  }

  Widget _buildSummaryInfo(WaterIntakeHistory? history) {
    if (history == null) {
      return const SizedBox.shrink();
    }

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
                'Total intake:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                history.formattedTotalAmount,
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
                'Daily goal:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                history.formattedDailyGoal,
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
            value: history.progressPercentage.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              history.goalMet ? Colors.green : Colors.white,
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 4),
          Text(
            '${(history.progressPercentage * 100).toStringAsFixed(1)}% of daily goal',
            style: TextStyle(
              color: history.goalMet ? Colors.green : Colors.white,
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

    // Làm tròn lên đến 100 gần nhất và thêm 100 để có khoảng trống
    return ((maxY / 100).ceil() * 100 + 100).toDouble();
  }
}
