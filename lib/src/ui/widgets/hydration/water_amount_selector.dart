import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Widget for selecting water amount
class WaterAmountSelector extends StatelessWidget {
  /// Currently selected amount
  final double? selectedAmount;

  /// Measurement unit
  final MeasureUnit measureUnit;

  /// Callback when an amount is selected
  final Function(double) onAmountSelected;

  /// Constructor
  const WaterAmountSelector({
    super.key,
    this.selectedAmount,
    required this.measureUnit,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Define common amounts based on measurement unit
    final List<double> commonAmounts = measureUnit == MeasureUnit.metric
        ? [100, 200, 250, 300, 500, 750, 1000] // ml
        : [4, 8, 12, 16, 20, 24, 32]; // fl oz

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
              'Select Amount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonAmounts.map((amount) {
                final isSelected = selectedAmount == amount;
                return _buildAmountItem(context, amount, isSelected);
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildCustomAmountSlider(context, commonAmounts),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountItem(BuildContext context, double amount, bool isSelected) {
    final String unit = measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';
    
    return ChoiceChip(
      label: Text('$amount $unit'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onAmountSelected(amount);
        }
      },
    );
  }

  Widget _buildCustomAmountSlider(BuildContext context, List<double> commonAmounts) {
    final double maxAmount = measureUnit == MeasureUnit.metric ? 1000 : 32;
    final double minAmount = measureUnit == MeasureUnit.metric ? 50 : 2;
    final String unit = measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';
    
    final double currentValue = selectedAmount ?? (measureUnit == MeasureUnit.metric ? 250 : 8);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Amount: ${currentValue.toStringAsFixed(0)} $unit',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Slider(
          value: currentValue,
          min: minAmount,
          max: maxAmount,
          divisions: measureUnit == MeasureUnit.metric ? 95 : 30,
          label: '${currentValue.toStringAsFixed(0)} $unit',
          onChanged: (value) {
            onAmountSelected(value);
          },
        ),
      ],
    );
  }
}
