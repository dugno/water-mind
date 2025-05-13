import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
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
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: viewModel.yearlyHistory.hasError
                ? Center(child: Text(
                    'Error: ${viewModel.yearlyHistory.error}',
                    style: const TextStyle(color: Colors.white),
                  ))
                : viewModel.yearlyHistory.value?.isNotEmpty == true
                    ? _buildYearlyChart(context, viewModel.yearlyHistory.value!)
                    : const Center(child: Text(
                        'No data for this year',
                        style: TextStyle(color: Colors.white),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    final year = viewModel.selectedYear;

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
                    backgroundColor: AppColor.thirdColor,
                    title: const Text('Select Year', style: TextStyle(color: Colors.white)),
                    content: SizedBox(
                      width: 300,
                      height: 300,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: Colors.white,
                            onPrimary: AppColor.thirdColor,
                            surface: AppColor.thirdColor,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: YearPicker(
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          selectedDate: DateTime(year),
                          onChanged: (DateTime dateTime) {
                            Navigator.pop(context, dateTime.year);
                          },
                        ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: year < DateTime.now().year
                ? () {
                    onYearChanged(year + 1);
                  }
                : null,
          ),
        ],
      ),
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
            padding: const EdgeInsets.only( right: 16, top: 16, bottom: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround, // Thay đổi alignment để phân bố không gian tốt hơn
                groupsSpace: 12, // Thêm khoảng cách giữa các cột
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    // Thêm đường ngang ở giá trị 0 để làm rõ biểu đồ
                    HorizontalLine(
                      y: 0,
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColor.primaryColor.withOpacity(0.85),
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = group.x.toInt();
                      final amount = rod.toY.toInt();
                      final monthName = DateTimeUtils.getMonthName(month, short: false);

                      return BarTooltipItem(
                        monthName,
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
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: '${viewModel.selectedYear}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
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
                        final month = value.toInt();
                        // Sử dụng số thay vì tên tháng
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            '$month', // Hiển thị số tháng
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
                      interval: 10000,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${(value / 1000).toInt()}k',
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
                  horizontalInterval: 10000,
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
    // Màu đồng nhất cho tất cả các cột
    final colors = [
      AppColor.thirdColor,
      AppColor.thirdColor.withOpacity(0.7),
    ];

    // Tạo danh sách các nhóm cột cho tất cả 12 tháng
    final List<BarChartGroupData> barGroups = [];

    // Map để lưu trữ giá trị của từng tháng
    final Map<int, double> monthValues = {};

    // Khởi tạo giá trị 0 cho tất cả các tháng
    for (int i = 1; i <= 12; i++) {
      monthValues[i] = 0;
    }

    // Cập nhật giá trị từ dữ liệu thực tế
    for (final spot in spots) {
      final month = spot.x.toInt();
      if (month >= 1 && month <= 12) {
        monthValues[month] = spot.y;
      }
    }

    // Tạo các nhóm cột cho tất cả 12 tháng
    for (int month = 1; month <= 12; month++) {
      final value = monthValues[month] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16, // Giảm độ rộng của cột để tránh tràn
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxY(spots) * 0.9,
                color: Colors.white.withOpacity(0.08), // Tăng độ tương phản của nền
              ),
              rodStackItems: [
                // Thêm đường viền sáng ở trên cùng để tạo hiệu ứng 3D
                BarChartRodStackItem(
                  value - 5 > 0 ? value - 5 : 0,
                  value,
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
        ),
      );
    }

    return barGroups;
  }



  /// Tính toán giá trị Y tối đa cho biểu đồ
  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10000;

    double maxY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    // Làm tròn lên đến 10000 gần nhất và thêm 10000 để có khoảng trống
    return ((maxY / 10000).ceil() * 10000 + 10000).toDouble();
  }

  Widget _buildSummaryInfo(double totalIntake, double averageMonthlyIntake) {
    // Tính trung bình mỗi ngày
    final averageDailyIntake = averageMonthlyIntake / 30;

    // Tính tổng lượng nước uống theo lít
    final totalLiters = totalIntake / 1000;

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
          // Tiêu đề năm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Year ${viewModel.selectedYear}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Thông tin tổng hợp
          Row(
            children: [
              // Cột bên trái - Tổng lượng nước
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Total yearly intake',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${totalIntake.toInt()}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'ml',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${totalLiters.toStringAsFixed(1)} liters)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Đường phân cách
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),

              // Cột bên phải - Trung bình
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Average intake',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${averageMonthlyIntake.toInt()} ml',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'per month',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${averageDailyIntake.toInt()} ml',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'per day',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
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
