import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/home/home_view_model.dart';
import 'package:water_mind/src/ui/widgets/calendar/controllers/calendar_controller.dart';
import 'package:water_mind/src/ui/widgets/calendar/widgets/week_view.dart';
import 'package:water_mind/src/ui/widgets/hydration/water_history_list.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_icon.dart';
import 'package:water_mind/src/ui/widgets/streak/streak_display_widget.dart';
import 'package:water_mind/src/ui/widgets/water_tank/animated_water_cup.dart';
import 'package:water_mind/src/ui/widgets/weather/weather_app_bar_widget.dart';

/// Home page of the application
@RoutePage()
class HomePage extends ConsumerWidget {
  /// Constructor
  const HomePage({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Widget buildSettingsCard(List<Widget> children) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.thirdColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: children,
        ),
      );
    }
    // Sử dụng HomeViewModel
    final homeViewModel = ref.watch(homeViewModelProvider);
    final homeViewModelNotifier = ref.read(homeViewModelProvider.notifier);

    // Lấy dữ liệu từ state
    final todayHistoryAsync = homeViewModel.todayHistory;
    final selectedDrinkType = homeViewModel.selectedDrinkType;
    final selectedAmount = homeViewModel.selectedAmount;
    final wavePhase = homeViewModel.wavePhase;

    // Xử lý lỗi và loading
    Widget buildContent() {
      return todayHistoryAsync.when(
        data: (todayHistory) {
          if (todayHistory == null) {
            return const Center(
              child: Text('Không có dữ liệu', style: TextStyle(color: Colors.white)),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: AppColor.thirdColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
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

              const SizedBox(height: 24),

              buildSettingsCard([
                // Water cup with animation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
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
                ),

                // Progress text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${todayHistory.formattedTotalAmount} / ${todayHistory.formattedDailyGoal}',
                        style: TextStyle(
                          color: todayHistory.goalMet ? AppColor.successColor : AppColor.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              buildSettingsCard([
                // Drink type selector with premium indicator
                ListTile(
                  leading: Icon(
                    selectedDrinkType.icon,
                    color: Colors.white,
                  ),
                  title: Row(
                    children: [
                      const Text(
                        'Loại đồ uống',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (selectedDrinkType.id != 'water')
                        const PremiumIcon(
                          size: 16,
                          color: Colors.white,
                          backgroundColor: AppColor.primaryColor,
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedDrinkType.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                  onTap: () {
                    // Hiển thị bottom sheet chọn loại đồ uống
                    homeViewModelNotifier.showDrinkTypeSelector(context);
                  },
                ),

                // Amount selector with premium indicator
                ListTile(
                  leading: const Icon(Icons.water_drop_outlined, color: Colors.white),
                  title: Row(
                    children: [
                      const Text(
                        'Lượng nước',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (selectedAmount != 200.0)
                        const PremiumIcon(
                          size: 16,
                          color: Colors.white,
                          backgroundColor: AppColor.primaryColor,
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${selectedAmount.toInt()} ${todayHistory.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                  onTap: () {
                    // Hiển thị bottom sheet chọn lượng nước
                    homeViewModelNotifier.showWaterAmountSelector(context);
                  },
                ),


              ]),

              const SizedBox(height: 24),

              // Streak display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const StreakDisplayWidget(),
              ),

              const SizedBox(height: 24),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.thirdColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: WaterHistoryList(
                  history: todayHistory,
                  onEntryDeleted: (entry) {
                    homeViewModelNotifier.deleteWaterIntakeEntry(entry.id);
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: Text(
            'Đã xảy ra lỗi: ${error.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
        ), loading: () { return const SizedBox.shrink(); },
      );
    }



    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with weather and profile
            Container(
              margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const WeatherAppBarWidget(),
                  Row(
                    children: [
                      // Premium button with text and icon
                      InkWell(
                        onTap: () {
                          // Navigate to premium subscription page
                          context.router.push(const PremiumSubscriptionRoute());
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColor.primaryColor, AppColor.thirdColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const PremiumIcon(
                                size: 20,
                                color: Colors.white,
                                showBackground: false,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.premium,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                ],
              ),
            ),

            // Main content
            Expanded(
              child: buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}
