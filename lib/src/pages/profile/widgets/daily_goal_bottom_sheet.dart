import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// Bottom sheet for setting daily water intake goal
class DailyGoalBottomSheet extends StatefulWidget {
  /// Initial value for the daily goal
  final int initialValue;

  /// Measurement unit
  final MeasureUnit measureUnit;

  /// Callback when the value is saved
  final Function(int) onSaved;

  /// Constructor
  const DailyGoalBottomSheet({
    super.key,
    required this.initialValue,
    required this.measureUnit,
    required this.onSaved,
  });

  /// Show the daily goal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required int initialValue,
    required MeasureUnit measureUnit,
    required Function(int) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.7,
      child: DailyGoalBottomSheet(
        initialValue: initialValue,
        measureUnit: measureUnit,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DailyGoalBottomSheet> createState() => _DailyGoalBottomSheetState();
}

class _DailyGoalBottomSheetState extends State<DailyGoalBottomSheet> with HapticFeedbackMixin {
  late TextEditingController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWheelPicker() {
    final unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'oz';
    final minValue = widget.measureUnit == MeasureUnit.metric ? 1000 : 30;
    final maxValue = widget.measureUnit == MeasureUnit.metric ? 5000 : 170;
    final step = widget.measureUnit == MeasureUnit.metric ? 100 : 5;

    // Calculate number of items and find the closest index
    final itemCount = ((maxValue - minValue) ~/ step) + 1;

    // Find the closest value that matches the step
    int closestValue = minValue;
    int minDiff = (minValue - _value).abs();

    for (int i = 0; i < itemCount; i++) {
      final currentValue = minValue + (i * step);
      final diff = (currentValue - _value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestValue = currentValue;
      }
    }

    // Calculate initial index
    final initialIndex = (closestValue - minValue) ~/ step;

    // Create controller
    final valueController = WheelPickerController(
      itemCount: itemCount,
      initialIndex: initialIndex,
    );

    return SizedBox(
      height: 200,
      child: WheelPicker(
        builder: (context, index) {
          final value = minValue + (index * step);
          final isSelected = value == closestValue;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: isSelected ? 22 : 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColor.thirdColor // Blue color for selected item
                      : Colors.white70, // Light color for better visibility on dark background
                ),
              ),
              if (isSelected)
                Text(
                  ' $unit',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.thirdColor, // Blue color for selected item
                  ),
                ),
            ],
          );
        },
        controller: valueController,
        selectedIndexColor: Colors.transparent,
        looping: false,
        style: const WheelPickerStyle(
          itemExtent: 40,
          squeeze: 1.0,
          diameterRatio: 1.5,
          magnification: 1.2,
          surroundingOpacity: 0.3,
        ),
        onIndexChanged: (index, _) {
          haptic(HapticFeedbackType.selection);
          final newValue = minValue + (index * step);
          setState(() {
            _value = newValue;
            _controller.text = _value.toString();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.measureUnit == MeasureUnit.metric ? 'ml' : 'oz';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.setDailyGoal,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            context.l10n.dailyGoalDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Text field for manual input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: context.l10n.dailyGoal,
              labelStyle: const TextStyle(color: Colors.white70),
              suffixText: unit,
              suffixStyle: const TextStyle(color: Colors.white),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _value = int.parse(value);
                });
              }
            },
          ),
        ),

        const SizedBox(height: 24),

        // Wheel picker for value selection
        _buildWheelPicker(),

        const SizedBox(height: 16),

        // Recommended range text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.measureUnit == MeasureUnit.metric
                ? context.l10n.recommendedRangeMetric
                : context.l10n.recommendedRangeImperial,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onSaved(_value);
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
