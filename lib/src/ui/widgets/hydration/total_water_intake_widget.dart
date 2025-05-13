import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/hydration/total_water_intake_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Widget hiển thị tổng lượng nước đã uống từ khi sử dụng app
class TotalWaterIntakeWidget extends ConsumerWidget {
  /// Constructor
  const TotalWaterIntakeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalWaterIntakeAsync = ref.watch(formattedTotalWaterIntakeProvider);

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
      child: totalWaterIntakeAsync.when(
        data: (data) => _buildTotalWaterIntakeInfo(context, data.amount, data.unit),
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

  Widget _buildTotalWaterIntakeInfo(BuildContext context, double totalAmount, unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.water_drop,
              color: Colors.lightBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.totalWaterIntake,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                formatTotalWaterIntake(totalAmount, unit),
                style: const TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.sinceUsingApp,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
