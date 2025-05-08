import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/utils/utils.dart';
import 'package:water_mind/src/pages/home/home_view_model.dart';
import 'package:water_mind/src/ui/widgets/calendar/widgets/week_view.dart';
import 'package:water_mind/src/ui/widgets/hydration/drink_type_selector.dart';
import 'package:water_mind/src/ui/widgets/hydration/water_amount_selector.dart';
import 'package:water_mind/src/ui/widgets/hydration/water_history_list.dart';
import 'package:water_mind/src/ui/widgets/water_tank/water_cup.dart';
import 'package:water_mind/src/ui/widgets/weather/weather_app_bar_widget.dart';

/// Home page of the application
@RoutePage()
class HomePage extends ConsumerWidget {
  /// Constructor
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider);
    final notifier = ref.read(homeViewModelProvider.notifier);

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
      body: Column(
        children: [
          // Fixed Calendar Header
          Container(
            color: AppColor.secondaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.thirdColor.withAlpha(51), // 0.2 opacity = 51 alpha
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 90,
                  child: WeekView(controller: viewModel.calendarController),
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
                    // Water cup
                    Center(
                      child: SizedBox(
                        height: 250,
                        child: WaterCup(
                          waterLevel: viewModel.todayHistory.progressPercentage.clamp(0.0, 1.0),
                          plantGrowth: viewModel.todayHistory.progressPercentage.clamp(0.0, 1.0),
                          wavePhase: viewModel.wavePhase,
                          dailyGoal: viewModel.todayHistory.dailyGoal,
                          majorTickInterval: viewModel.todayHistory.measureUnit == MeasureUnit.metric ? 500 : 16,
                          minorTickInterval: viewModel.todayHistory.measureUnit == MeasureUnit.metric ? 100 : 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Drink type selector
                    DrinkTypeSelector(
                      drinkTypes: DrinkTypes.all,
                      selectedDrinkType: viewModel.selectedDrinkType ?? DrinkTypes.water,
                      onDrinkTypeSelected: notifier.setSelectedDrinkType,
                    ),
                    const SizedBox(height: 16),

                    // Water amount selector
                    WaterAmountSelector(
                      selectedAmount: viewModel.selectedAmount ?? 200.0,
                      measureUnit: viewModel.userModel.measureUnit,
                      onAmountSelected: notifier.setSelectedAmount,
                    ),
                    const SizedBox(height: 16),

                    // Add button
                    ElevatedButton.icon(
                      onPressed: notifier.addWaterIntakeEntry,
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
                      history: viewModel.todayHistory,
                      onEntryDeleted: notifier.deleteWaterIntakeEntry,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
