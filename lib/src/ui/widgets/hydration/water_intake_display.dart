import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/hydration/hydration.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Widget to display the calculated daily water intake
class WaterIntakeDisplay extends ConsumerWidget {
  /// The user onboarding model containing user parameters
  final UserOnboardingModel userModel;

  /// Optional callback when the water intake is calculated
  final Function(HydrationModel)? onWaterIntakeCalculated;

  /// Constructor
  const WaterIntakeDisplay({
    super.key,
    required this.userModel,
    this.onWaterIntakeCalculated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate water intake
    final hydrationService = ref.watch(hydrationServiceProvider);
    final hydrationModel = hydrationService.calculateFromUserModel(userModel);

    // Call the callback if provided
    if (onWaterIntakeCalculated != null) {
      onWaterIntakeCalculated!(hydrationModel);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon for water
        const Icon(
          Icons.water_drop,
          size: 60,
          color: Colors.white,
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          context.l10n.dailyWaterIntake,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Water intake amount
        Text(
          hydrationModel.getFormattedWaterIntake(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Recommendation text
        Text(
          context.l10n.recommendedIntake,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
