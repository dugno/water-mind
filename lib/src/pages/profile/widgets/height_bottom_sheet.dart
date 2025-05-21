import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// Bottom sheet for selecting height
class HeightBottomSheet extends StatefulWidget {
  /// Initial height
  final double? initialHeight;

  /// Measurement unit
  final MeasureUnit measureUnit;

  /// Callback when height is saved
  final Function(double) onSaved;

  /// Constructor
  const HeightBottomSheet({
    super.key,
    this.initialHeight,
    required this.measureUnit,
    required this.onSaved,
  });

  /// Show the height bottom sheet
  static Future<void> show({
    required BuildContext context,
    double? initialHeight,
    required MeasureUnit measureUnit,
    required Function(double) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.6,
      child: HeightBottomSheet(
        initialHeight: initialHeight,
        measureUnit: measureUnit,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<HeightBottomSheet> createState() => _HeightBottomSheetState();
}

class _HeightBottomSheetState extends State<HeightBottomSheet> with HapticFeedbackMixin {
  late double _height;

  // For wheel pickers
  late int _heightWhole;
  late int _heightDecimal;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight ?? (widget.measureUnit == MeasureUnit.metric ? 170 : 67);

    // Initialize wheel picker values
    _initializeWheelPickerValues();
  }

  void _initializeWheelPickerValues() {
    if (widget.measureUnit == MeasureUnit.metric) {
      _heightWhole = _height.toInt();
      _heightDecimal = ((_height - _heightWhole) * 10).round();
    } else {
      // For imperial, height is in inches
      _heightWhole = (_height / 12).floor(); // Feet
      _heightDecimal = (_height % 12).round(); // Inches
    }
  }

  void _updateHeightFromWheelPicker() {
    if (widget.measureUnit == MeasureUnit.metric) {
      _height = _heightWhole + (_heightDecimal / 10);
    } else {
      _height = (_heightWhole * 12.0) + _heightDecimal.toDouble();
    }
  }

  Widget _buildHeightPicker() {
    if (widget.measureUnit == MeasureUnit.metric) {
      return _buildMetricHeightPicker();
    } else {
      return _buildImperialHeightPicker();
    }
  }

  Widget _buildMetricHeightPicker() {
    // Generate height values for metric (cm)
    const int minHeight = 100;
    const int maxHeight = 220;

    // Ensure height is within range
    if (_heightWhole < minHeight) _heightWhole = minHeight;
    if (_heightWhole > maxHeight) _heightWhole = maxHeight;

    // Calculate initial index
    final initialIndex = (_heightWhole - minHeight).clamp(0, maxHeight - minHeight);

    // Create controller
    final heightController = WheelPickerController(
      itemCount: maxHeight - minHeight + 1,
      initialIndex: initialIndex,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26), // 0.1 opacity
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 200,
        child: WheelPicker(
          builder: (context, index) {
            final value = minHeight + index;
            final isSelected = value == _heightWhole;

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
                  const Text(
                    ' cm',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColor.thirdColor, // Blue color for selected item
                    ),
                  ),
              ],
            );
          },
          controller: heightController,
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
            setState(() {
              _heightWhole = minHeight + index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImperialHeightPicker() {
    // For imperial, we need feet and inches
    const int minFeet = 3;
    const int maxFeet = 7;
    const int maxInches = 11;

    // Ensure height is within range
    if (_heightWhole < minFeet) _heightWhole = minFeet;
    if (_heightWhole > maxFeet) _heightWhole = maxFeet;
    if (_heightDecimal < 0) _heightDecimal = 0;
    if (_heightDecimal > maxInches) _heightDecimal = maxInches;

    // Calculate initial indices
    final feetIndex = (_heightWhole - minFeet).clamp(0, maxFeet - minFeet);
    final inchesIndex = _heightDecimal.clamp(0, maxInches);

    // Create controllers
    final feetController = WheelPickerController(
      itemCount: maxFeet - minFeet + 1,
      initialIndex: feetIndex,
    );

    final inchesController = WheelPickerController(
      itemCount: maxInches + 1,
      initialIndex: inchesIndex,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26), // 0.1 opacity
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            // Feet wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) {
                  final value = minFeet + index;
                  final isSelected = value == _heightWhole;

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
                        const Text(
                          ' ft',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.thirdColor, // Blue color for selected item
                          ),
                        ),
                    ],
                  );
                },
                controller: feetController,
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
                  setState(() {
                    _heightWhole = minFeet + index;
                  });
                },
              ),
            ),

            // Inches wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) {
                  final value = index;
                  final isSelected = value == _heightDecimal;

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
                        const Text(
                          ' in',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.thirdColor, // Blue color for selected item
                          ),
                        ),
                    ],
                  );
                },
                controller: inchesController,
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
                  setState(() {
                    _heightDecimal = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.height,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Height picker
        _buildHeightPicker(),

        const SizedBox(height: 16),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              haptic(HapticFeedbackType.success);
              _updateHeightFromWheelPicker();
              widget.onSaved(_height);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.thirdColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.l10n.save),
          ),
        ),
      ],
    );
  }
}
