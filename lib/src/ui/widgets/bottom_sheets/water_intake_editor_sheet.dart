import 'package:flutter/material.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// A bottom sheet for editing water intake with all options in one screen
class WaterIntakeEditorSheet extends StatefulWidget {
  /// The initial amount of water
  final double initialAmount;

  /// The initial time of water intake
  final TimeOfDay initialTime;

  /// The initial drink type
  final DrinkType initialDrinkType;

  /// The initial note (optional)
  final String? initialNote;

  /// The measurement unit (metric or imperial)
  final MeasureUnit measureUnit;

  /// Constructor
  const WaterIntakeEditorSheet({
    super.key,
    required this.initialAmount,
    required this.initialTime,
    required this.initialDrinkType,
    this.initialNote,
    required this.measureUnit,
  });

  /// Show the water intake editor bottom sheet
  static Future<WaterIntakeEditResult?> show({
    required BuildContext context,
    required double initialAmount,
    required TimeOfDay initialTime,
    required DrinkType initialDrinkType,
    String? initialNote,
    required MeasureUnit measureUnit,
  }) {
    return BaseBottomSheet.show<WaterIntakeEditResult>(
      context: context,
      maxHeightFactor: 0.8,
      child: WaterIntakeEditorSheet(
        initialAmount: initialAmount,
        initialTime: initialTime,
        initialDrinkType: initialDrinkType,
        initialNote: initialNote,
        measureUnit: measureUnit,
      ),
    );
  }

  @override
  State<WaterIntakeEditorSheet> createState() => _WaterIntakeEditorSheetState();
}

/// Result of the water intake editor
class WaterIntakeEditResult {
  /// The amount of water
  final double amount;

  /// The time of water intake
  final TimeOfDay time;

  /// The drink type
  final DrinkType drinkType;

  /// The note (optional)
  final String? note;

  /// Constructor
  WaterIntakeEditResult({
    required this.amount,
    required this.time,
    required this.drinkType,
    this.note,
  });
}

class _WaterIntakeEditorSheetState extends State<WaterIntakeEditorSheet> {
  late double _amount;
  late TimeOfDay _time;
  late DrinkType _drinkType;
  late TextEditingController _noteController;

  // For the amount picker
  late final List<double> _amountValues;
  late int _selectedAmountIndex;

  // For the time picker
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
    _time = widget.initialTime;
    _drinkType = widget.initialDrinkType;
    _noteController = TextEditingController(text: widget.initialNote ?? '');

    // Setup amount values based on measurement unit
    if (widget.measureUnit == MeasureUnit.metric) {
      // Metric: 50ml to 1000ml in 50ml increments
      _amountValues = List.generate(20, (index) => 50.0 * (index + 1));
    } else {
      // Imperial: 2oz to 32oz in 2oz increments
      _amountValues = List.generate(16, (index) => 2.0 * (index + 1));
    }

    // Find closest amount value index
    _selectedAmountIndex = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < _amountValues.length; i++) {
      final diff = (_amountValues[i] - _amount).abs();
      if (diff < minDiff) {
        minDiff = diff;
        _selectedAmountIndex = i;
      }
    }

    // Initialize time values
    _selectedHour = _time.hour;
    _selectedMinute = _time.minute;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Amount display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _amount.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // Amount picker
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: PageController(
              initialPage: _selectedAmountIndex,
              viewportFraction: 0.3,
            ),
            onPageChanged: (index) {
              setState(() {
                _selectedAmountIndex = index;
                _amount = _amountValues[index];
              });
              HapticService.instance.feedback(HapticFeedbackType.selection);
            },
            itemCount: _amountValues.length,
            itemBuilder: (context, index) {
              final value = _amountValues[index];
              final isSelected = index == _selectedAmountIndex;

              return Center(
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Time picker
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hours
            Expanded(
              child: SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: PageController(
                    initialPage: _selectedHour,
                    viewportFraction: 0.4,
                  ),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedHour = index % 24;
                      _time = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
                    });
                    HapticService.instance.feedback(HapticFeedbackType.selection);
                  },
                  itemCount: 24 * 3, // Loop through hours 3 times for better scrolling
                  itemBuilder: (context, index) {
                    final hour = index % 24;
                    final isSelected = hour == _selectedHour;

                    return Center(
                      child: Text(
                        hour.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 22 : 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Separator
            Text(
              ':',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),

            // Minutes
            Expanded(
              child: SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: PageController(
                    initialPage: _selectedMinute,
                    viewportFraction: 0.4,
                  ),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedMinute = index % 60;
                      _time = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
                    });
                    HapticService.instance.feedback(HapticFeedbackType.selection);
                  },
                  itemCount: 60 * 3, // Loop through minutes 3 times for better scrolling
                  itemBuilder: (context, index) {
                    final minute = index % 60;
                    final isSelected = minute == _selectedMinute;

                    return Center(
                      child: Text(
                        minute.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 22 : 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Drink type selector
        Text(
          'Drink Type',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: DrinkTypes.all.length,
            itemBuilder: (context, index) {
              final drinkType = DrinkTypes.all[index];
              final isSelected = drinkType.id == _drinkType.id;

              return GestureDetector(
                onTap: () {
                  HapticService.instance.feedback(HapticFeedbackType.selection);
                  setState(() {
                    _drinkType = drinkType;
                  });
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? drinkType.color.withAlpha(51) : Colors.transparent, // 0.2 opacity = 51 alpha
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? drinkType.color : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(drinkType.icon, color: drinkType.color),
                      const SizedBox(height: 4),
                      Text(
                        drinkType.name,
                        style: TextStyle(
                          fontSize: 12,
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
        ),

        const SizedBox(height: 16),

        // Note input
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            hintText: 'Optional',
            border: OutlineInputBorder(),
          ),
          maxLines: 1,
        ),

        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    WaterIntakeEditResult(
                      amount: _amount,
                      time: _time,
                      drinkType: _drinkType,
                      note: _noteController.text.isEmpty ? null : _noteController.text,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
