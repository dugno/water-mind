import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/hydration/hydration.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_provider.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';

/// Widget to display the calculated daily water intake
class WaterIntakeDisplay extends ConsumerWidget {
  /// The user onboarding model containing user parameters
  final UserOnboardingModel userModel;

  /// Optional callback when the water intake is calculated
  final Function(HydrationModel)? onWaterIntakeCalculated;

  /// Whether to save the calculated water intake to the database
  final bool saveToDatabase;

  /// Constructor
  const WaterIntakeDisplay({
    super.key,
    required this.userModel,
    this.onWaterIntakeCalculated,
    this.saveToDatabase = true,
  });

  /// Save the recommended water intake to the database
  Future<void> _saveRecommendedIntakeToDatabase(WidgetRef ref, HydrationModel hydrationModel) async {
    try {
      // Get the repository
      final waterIntakeRepository = ref.read(waterIntakeRepositoryProvider);

      // Get today's date
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      // Get current history if it exists
      final currentHistory = await waterIntakeRepository.getWaterIntakeHistory(normalizedToday);

      if (currentHistory != null) {
        // Update the daily goal with the calculated recommendation
        final updatedHistory = WaterIntakeHistory(
          date: currentHistory.date,
          entries: currentHistory.entries,
          dailyGoal: hydrationModel.dailyWaterIntake,
          measureUnit: hydrationModel.measureUnit,
        );

        // Save the updated history
        await waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);
        AppLogger.info('Updated daily goal to ${hydrationModel.dailyWaterIntake} ${hydrationModel.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
      } else {
        // Create a new history with the calculated recommendation
        final newHistory = WaterIntakeHistory(
          date: normalizedToday,
          entries: [],
          dailyGoal: hydrationModel.dailyWaterIntake,
          measureUnit: hydrationModel.measureUnit,
        );

        // Save the new history
        await waterIntakeRepository.saveWaterIntakeHistory(newHistory);
        AppLogger.info('Created new history with daily goal: ${hydrationModel.dailyWaterIntake} ${hydrationModel.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving recommended water intake to database');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate water intake
    final hydrationService = ref.watch(hydrationServiceProvider);
    final hydrationModel = hydrationService.calculateFromUserModel(userModel);

    // Call the callback if provided
    if (onWaterIntakeCalculated != null) {
      onWaterIntakeCalculated!(hydrationModel);
    }

    // Save the calculated water intake to the database if requested
    if (saveToDatabase) {
      _saveRecommendedIntakeToDatabase(ref, hydrationModel);
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
