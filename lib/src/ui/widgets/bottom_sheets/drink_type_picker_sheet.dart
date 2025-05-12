import 'package:flutter/material.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// A bottom sheet for selecting drink type
class DrinkTypePickerSheet extends StatefulWidget {
  /// The initially selected drink type
  final DrinkType? initialDrinkType;

  /// Constructor
  const DrinkTypePickerSheet({
    super.key,
    this.initialDrinkType,
  });

  /// Show the drink type picker bottom sheet
  static Future<DrinkType?> show({
    required BuildContext context,
    DrinkType? initialDrinkType,
  }) {
    return BaseBottomSheet.show<DrinkType>(
      context: context,
      maxHeightFactor: 0.6,
      child: DrinkTypePickerSheet(
        initialDrinkType: initialDrinkType,
      ),
    );
  }

  @override
  State<DrinkTypePickerSheet> createState() => _DrinkTypePickerSheetState();
}

class _DrinkTypePickerSheetState extends State<DrinkTypePickerSheet> with HapticFeedbackMixin {
  late DrinkType _selectedDrinkType;

  @override
  void initState() {
    super.initState();
    _selectedDrinkType = widget.initialDrinkType ?? DrinkTypes.water;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.selectDrinkType,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // Drink types grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: DrinkTypes.all.length,
          itemBuilder: (context, index) {
            final drinkType = DrinkTypes.all[index];
            final isSelected = drinkType.id == _selectedDrinkType.id;
            
            return GestureDetector(
              onTap: () {
                haptic(HapticFeedbackType.selection);
                setState(() {
                  _selectedDrinkType = drinkType;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? drinkType.color.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? drinkType.color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      drinkType.icon,
                      color: drinkType.color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      drinkType.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? drinkType.color : Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  haptic(HapticFeedbackType.light);
                  Navigator.of(context).pop();
                },
                child: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  haptic(HapticFeedbackType.medium);
                  Navigator.of(context).pop(_selectedDrinkType);
                },
                child: Text(context.l10n.select),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
