import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/hydration/total_water_intake_provider.dart';
import 'package:water_mind/src/core/services/streak/streak_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Widget hiển thị thông tin streak và tổng lượng nước đã uống trong một row
class StatsRowWidget extends ConsumerWidget {
  /// Constructor
  const StatsRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStreakAsync = ref.watch(userStreakProvider);
    final hasTodayStreakAsync = ref.watch(hasTodayStreakProvider);
    final totalWaterIntakeAsync = ref.watch(formattedTotalWaterIntakeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
      child: Row(
        children: [
          // Streak info
          Expanded(
            child: userStreakAsync.when(
              data: (streak) {
                if (streak == null) {
                  return _buildNoStreakInfo(context);
                }
                return _buildStreakInfo(
                  context,
                  streak.currentStreak,
                  hasTodayStreakAsync.value ?? false,
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.red[300], fontSize: 12),
                ),
              ),
            ),
          ),

          // Divider
          Container(
            height: 50,
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // Total water intake info
          Expanded(
            child: totalWaterIntakeAsync.when(
              data: (data) => _buildTotalWaterIntakeInfo(
                context,
                data.amount,
                data.unit,
              ),
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.red[300], fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStreakInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.streak,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '0 ${context.l10n.days}',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakInfo(
    BuildContext context,
    int currentStreak,
    bool hasTodayStreak,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: hasTodayStreak ? Colors.orange : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.streak,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!hasTodayStreak) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$currentStreak ${context.l10n.days}',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalWaterIntakeInfo(BuildContext context, double totalAmount, unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop,
              color: Colors.lightBlue,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.totalWaterIntake,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          formatTotalWaterIntake(totalAmount, unit),
          style: const TextStyle(
            color: Colors.lightBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
