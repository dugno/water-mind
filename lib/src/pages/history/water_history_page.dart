import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/history/water_history_view_model.dart';
import 'package:water_mind/src/pages/history/widgets/daily_chart.dart';
import 'package:water_mind/src/pages/history/widgets/monthly_chart.dart';
import 'package:water_mind/src/pages/history/widgets/weekly_chart.dart';
import 'package:water_mind/src/pages/history/widgets/yearly_chart.dart';

/// Màn hình lịch sử uống nước
@RoutePage()
class WaterHistoryPage extends ConsumerStatefulWidget {
  /// Constructor
  const WaterHistoryPage({super.key});

  @override
  ConsumerState<WaterHistoryPage> createState() => _WaterHistoryPageState();
}

class _WaterHistoryPageState extends ConsumerState<WaterHistoryPage> with SingleTickerProviderStateMixin, HapticFeedbackMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(waterHistoryViewModelProvider.notifier).setActiveTab(_tabController.index);
        // Cập nhật giao diện khi tab thay đổi
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Xây dựng các card cho các tab
  Widget _buildTabSelectionCards() {
    return Row(
      children: [
        // Tab Ngày
        Expanded(
          child: _buildTabCard(
            index: 0,
            icon: Icons.calendar_today,
            title: context.l10n.day,
          ),
        ),

        // Tab Tuần
        Expanded(
          child: _buildTabCard(
            index: 1,
            icon: Icons.date_range,
            title: context.l10n.week,
          ),
        ),

        // Tab Tháng
        Expanded(
          child: _buildTabCard(
            index: 2,
            icon: Icons.calendar_month,
            title: context.l10n.month,
          ),
        ),

        // Tab Năm
        Expanded(
          child: _buildTabCard(
            index: 3,
            icon: Icons.view_timeline,
            title: context.l10n.year,
          ),
        ),
      ],
    );
  }

  /// Xây dựng một card cho tab
  Widget _buildTabCard({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        haptic(HapticFeedbackType.selection);
        _tabController.animateTo(index);
      },
      child: Card(
        color: isSelected
            ? AppColor.thirdColor
            : AppColor.thirdColor.withOpacity(0.5),
        elevation: isSelected ? 4 : 1,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(waterHistoryViewModelProvider);
    final notifier = ref.read(waterHistoryViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: Text(
          context.l10n.waterHistory,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Nút tạo dữ liệu giả
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'week') {
                await notifier.generateFakeDataForLastWeek();
              } else if (value == 'month') {
                await notifier.generateFakeDataForLastMonth();
              }

              // Tải lại dữ liệu
              notifier.setActiveTab(viewModel.activeTab);

              // Hiển thị thông báo
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã tạo dữ liệu giả cho ${value == 'week' ? '7 ngày' : '30 ngày'} gần đây'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'week',
                child: Text('Tạo dữ liệu giả cho 7 ngày'),
              ),
              const PopupMenuItem<String>(
                value: 'month',
                child: Text('Tạo dữ liệu giả cho 30 ngày'),
              ),
            ],
            icon: const Icon(Icons.data_array, color: Colors.white),
            tooltip: 'Tạo dữ liệu giả',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selection cards
          Container(
            margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    context.l10n.waterHistory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildTabSelectionCards(),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Ngày
                DailyChartTab(
                  viewModel: viewModel,
                  onDateChanged: notifier.setSelectedDate,
                ),

                // Tab Tuần
                WeeklyChartTab(
                  viewModel: viewModel,
                  onWeekChanged: notifier.setSelectedWeek,
                ),

                // Tab Tháng
                MonthlyChartTab(
                  viewModel: viewModel,
                  onMonthChanged: notifier.setSelectedMonth,
                ),

                // Tab Năm
                YearlyChartTab(
                  viewModel: viewModel,
                  onYearChanged: notifier.setSelectedYear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
