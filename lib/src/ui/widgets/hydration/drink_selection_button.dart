import 'package:flutter/material.dart';
import 'package:water_mind/src/core/models/drink_type.dart';

/// A button for displaying and selecting drink type
class DrinkSelectionButton extends StatelessWidget {
  /// The selected drink type
  final DrinkType drinkType;

  /// Callback when the button is tapped
  final VoidCallback onTap;

  /// Constructor
  const DrinkSelectionButton({
    super.key,
    required this.drinkType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: drinkType.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: drinkType.color,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              drinkType.icon,
              color: drinkType.color,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              drinkType.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: drinkType.color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: drinkType.color,
            ),
          ],
        ),
      ),
    );
  }
}
