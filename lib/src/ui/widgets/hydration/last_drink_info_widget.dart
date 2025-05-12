import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/providers/user_preferences_providers.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Widget hiển thị thông tin về lần uống nước gần nhất
class LastDrinkInfoWidget extends ConsumerWidget {
  /// Constructor
  const LastDrinkInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferencesAsync = ref.watch(userPreferencesProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: userPreferencesAsync.when(
          data: (preferences) {
            if (preferences == null || preferences.lastDrinkTypeId == null) {
              return _buildNoLastDrinkInfo(context);
            }

            final lastDrinkType = ref.watch(lastDrinkTypeProvider(preferences));
            final lastDrinkAmount = ref.watch(lastDrinkAmountProvider(preferences));

            return _buildLastDrinkInfo(context, lastDrinkType, lastDrinkAmount, preferences.measureUnit);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error loading preferences: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoLastDrinkInfo(BuildContext context) {
    return Center(
      child: Text(
        'No last drink information available',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildLastDrinkInfo(
    BuildContext context,
    DrinkType drinkType,
    double amount,
    MeasureUnit measureUnit,
  ) {
    final formattedAmount = _formatAmount(amount, measureUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.lastDrink,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              drinkType.icon,
              size: 40,
              color: drinkType.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drinkType.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    formattedAmount,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(double amount, MeasureUnit measureUnit) {
    if (measureUnit == MeasureUnit.metric) {
      if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(1)} L';
      } else {
        return '${amount.toStringAsFixed(0)} ml';
      }
    } else {
      return '${amount.toStringAsFixed(1)} fl oz';
    }
  }
}
