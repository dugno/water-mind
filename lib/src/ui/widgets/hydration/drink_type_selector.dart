import 'package:flutter/material.dart';
import 'package:water_mind/src/core/models/drink_type.dart';

/// Widget for selecting drink types
class DrinkTypeSelector extends StatelessWidget {
  /// List of available drink types
  final List<DrinkType> drinkTypes;

  /// Currently selected drink type
  final DrinkType? selectedDrinkType;

  /// Callback when a drink type is selected
  final Function(DrinkType) onDrinkTypeSelected;

  /// Constructor
  const DrinkTypeSelector({
    super.key,
    required this.drinkTypes,
    this.selectedDrinkType,
    required this.onDrinkTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Drink Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: drinkTypes.map((drinkType) {
                final isSelected = selectedDrinkType?.id == drinkType.id;
                return _buildDrinkTypeItem(context, drinkType, isSelected);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkTypeItem(
      BuildContext context, DrinkType drinkType, bool isSelected) {
    return InkWell(
      onTap: () => onDrinkTypeSelected(drinkType),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? drinkType.color.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? drinkType.color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              drinkType.icon,
              color: drinkType.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              drinkType.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? drinkType.color : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
