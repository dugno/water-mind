import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/water_cup/simple_water_cup.dart';

/// A button for displaying and selecting water amount
class AmountSelectionButton extends StatelessWidget {
  /// The selected amount
  final double amount;

  /// The measurement unit
  final MeasureUnit measureUnit;

  /// Callback when the button is tapped
  final VoidCallback onTap;

  /// Constructor
  const AmountSelectionButton({
    super.key,
    required this.amount,
    required this.measureUnit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unit = measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleWaterCup(
              currentWaterAmount: amount,
              maxWaterAmount: 1000,
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            Text(
              '${amount.toInt()} $unit',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
