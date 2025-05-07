import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _WaterHistoryPageState extends ConsumerState<WaterHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(waterHistoryViewModelProvider.notifier).setActiveTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(waterHistoryViewModelProvider);
    final notifier = ref.read(waterHistoryViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.waterHistory),
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
            icon: const Icon(Icons.data_array),
            tooltip: 'Tạo dữ liệu giả',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.l10n.day),
            Tab(text: context.l10n.week),
            Tab(text: context.l10n.month),
            Tab(text: context.l10n.year),
          ],
        ),
      ),
      body: TabBarView(
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
    );
  }
}
