import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.dailyWaterIntake,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              hydrationModel.getFormattedWaterIntake(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildFactorsList(context, hydrationModel),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorsList(BuildContext context, HydrationModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.calculationFactors,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...model.calculationFactors.entries
            .where((entry) =>
                !entry.key.startsWith('_')) // Filter out hidden factors
            .map((entry) {
          final factorName = _getFactorName(context, entry.key);
          // Skip if factor name is empty
          if (factorName.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  factorName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '×${entry.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getFactorName(BuildContext context, String factorKey) {
    switch (factorKey) {
      case 'base':
        return context.l10n.baseIntake;
      case 'activity':
        return context.l10n.activityFactor;
      case 'environment':
        return context.l10n
            .environmentFactor; // Now represents the combined environment factor
      case 'gender':
        return context.l10n.genderFactor;
      case 'age':
        return context.l10n.ageFactor;
      case 'awakeHours':
        return context.l10n.awakeHoursFactor;
      // Hidden factors (prefixed with underscore) are not displayed in the UI
      case '_livingEnvironment':
      case '_weather':
        return ''; // Don't display these in the UI
      default:
        return factorKey;
    }
  }
}
