import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/streak/streak_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Widget hiển thị thông tin streak của người dùng
class StreakDisplayWidget extends ConsumerWidget {
  /// Constructor
  const StreakDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStreakAsync = ref.watch(userStreakProvider);
    final hasTodayStreakAsync = ref.watch(hasTodayStreakProvider);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: userStreakAsync.when(
        data: (streak) {
          if (streak == null) {
            return _buildNoStreakInfo(context);
          }

          return _buildStreakInfo(
            context,
            streak.currentStreak,
            streak.longestStreak,
            hasTodayStreakAsync.value ?? false,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildNoStreakInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.streak,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.noStreakYet,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.drinkWaterToStartStreak,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakInfo(
    BuildContext context,
    int currentStreak,
    int longestStreak,
    bool hasTodayStreak,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.streak,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (!hasTodayStreak)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.drinkTodayToKeepStreak,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStreakCard(
                context,
                currentStreak,
                context.l10n.currentStreak,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStreakCard(
                context,
                longestStreak,
                context.l10n.longestStreak,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    int streakCount,
    String title,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '$streakCount ${context.l10n.days}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
