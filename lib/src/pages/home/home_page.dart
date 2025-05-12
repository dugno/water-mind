import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/home/home_view_model.dart';
import 'package:water_mind/src/ui/widgets/calendar/controllers/calendar_controller.dart';
import 'package:water_mind/src/ui/widgets/calendar/widgets/week_view.dart';
import 'package:water_mind/src/ui/widgets/hydration/amount_selection_button.dart';
import 'package:water_mind/src/ui/widgets/hydration/drink_selection_button.dart';
import 'package:water_mind/src/ui/widgets/hydration/water_history_list.dart';
import 'package:water_mind/src/ui/widgets/water_tank/animated_water_cup.dart';
import 'package:water_mind/src/ui/widgets/weather/weather_app_bar_widget.dart';

/// Home page of the application
@RoutePage()
class HomePage extends ConsumerWidget {
  /// Constructor
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng HomeViewModel
    final homeViewModel = ref.watch(homeViewModelProvider);
    final homeViewModelNotifier = ref.read(homeViewModelProvider.notifier);

    // Lấy dữ liệu từ state
    final todayHistoryAsync = homeViewModel.todayHistory;
    final userModelAsync = homeViewModel.userModel;
    final selectedDrinkType = homeViewModel.selectedDrinkType ?? DrinkTypes.water;
    final selectedAmount = homeViewModel.selectedAmount ?? 200.0;
    final wavePhase = homeViewModel.wavePhase;

    // Xử lý lỗi và loading
    Widget buildContent() {
      return todayHistoryAsync.when(
        data: (todayHistory) {
          if (todayHistory == null) {
            return const Center(
              child: Text('Không có dữ liệu'),
            );
          }

          return Column(
            children: [
              // Calendar
              Container(
                color: AppColor.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.thirdColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 90,
                      child: WeekView(
                        controller: CalendarController(),
                        // Sử dụng onTap của DayView trong WeekView
                      ),
                    ),
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColor.secondaryColor,
                        AppColor.thirdColor,
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Water cup with animation
                        Center(
                          child: SizedBox(
                            height: 250,
                            child: AnimatedWaterCup(
                              waterLevel: todayHistory.progressPercentage.clamp(0.0, 1.0),
                              plantGrowth: todayHistory.progressPercentage.clamp(0.0, 1.0),
                              wavePhase: wavePhase,
                              dailyGoal: todayHistory.dailyGoal,
                              majorTickInterval: todayHistory.measureUnit == MeasureUnit.metric ? 500 : 16,
                              minorTickInterval: todayHistory.measureUnit == MeasureUnit.metric ? 100 : 4,
                              previousWaterLevel: homeViewModel.previousWaterLevel,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Drink type and amount selectors in a row
                        Row(
                          children: [
                            // Drink type selector
                            Expanded(
                              child: DrinkSelectionButton(
                                drinkType: selectedDrinkType,
                                onTap: () {
                                  // Hiển thị bottom sheet chọn loại đồ uống
                                  homeViewModelNotifier.showDrinkTypeSelector(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Water amount selector
                            Expanded(
                              child: AmountSelectionButton(
                                amount: selectedAmount,
                                measureUnit: userModelAsync.valueOrNull?.measureUnit ?? MeasureUnit.metric,
                                onTap: () {
                                  // Hiển thị bottom sheet chọn lượng nước
                                  homeViewModelNotifier.showWaterAmountSelector(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Add button
                        ElevatedButton.icon(
                          onPressed: homeViewModelNotifier.addWaterIntakeEntry,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Water Intake'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColor.thirdColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Water history list
                        WaterHistoryList(
                          history: todayHistory,
                          onEntryDeleted: (entry) {
                            homeViewModelNotifier.deleteWaterIntakeEntry(entry.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Đã xảy ra lỗi: ${error.toString()}'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: const WeatherAppBarWidget(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              // Navigate to profile page
              context.router.push(const ProfileRoute());
            },
          ),
        ],
      ),
      body: buildContent(),
    );
  }
}
