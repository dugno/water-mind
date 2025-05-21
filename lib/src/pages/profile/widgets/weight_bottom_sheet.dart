import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// Bottom sheet for selecting weight
class WeightBottomSheet extends StatefulWidget {
  /// Initial weight
  final double? initialWeight;

  /// Measurement unit
  final MeasureUnit measureUnit;

  /// Callback when weight is saved
  final Function(double) onSaved;

  /// Constructor
  const WeightBottomSheet({
    super.key,
    this.initialWeight,
    required this.measureUnit,
    required this.onSaved,
  });

  /// Show the weight bottom sheet
  static Future<void> show({
    required BuildContext context,
    double? initialWeight,
    required MeasureUnit measureUnit,
    required Function(double) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.6,
      child: WeightBottomSheet(
        initialWeight: initialWeight,
        measureUnit: measureUnit,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<WeightBottomSheet> createState() => _WeightBottomSheetState();
}

class _WeightBottomSheetState extends State<WeightBottomSheet> with HapticFeedbackMixin {
  late double _weight;

  // For wheel pickers
  late int _weightWhole;
  late int _weightDecimal;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight ?? (widget.measureUnit == MeasureUnit.metric ? 70 : 154);

    // Initialize wheel picker values
    _initializeWheelPickerValues();
  }

  void _initializeWheelPickerValues() {
    _weightWhole = _weight.toInt();
    _weightDecimal = ((_weight - _weightWhole) * 10).round();
  }

  void _updateWeightFromWheelPicker() {
    _weight = _weightWhole + (_weightDecimal / 10);
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Đảm bảo rằng tất cả các tài nguyên được giải phóng
    super.dispose();
  }

  Widget _buildWeightPicker() {
    if (widget.measureUnit == MeasureUnit.metric) {
      return _buildMetricWeightPicker();
    } else {
      return _buildImperialWeightPicker();
    }
  }

  Widget _buildMetricWeightPicker() {
    // Generate weight values for metric (kg)
    const int minWeight = 30;
    const int maxWeight = 150;

    // Ensure weight is within range
    if (_weightWhole < minWeight) _weightWhole = minWeight;
    if (_weightWhole > maxWeight) _weightWhole = maxWeight;

    // Calculate initial indices
    final wholeIndex = (_weightWhole - minWeight).clamp(0, maxWeight - minWeight);
    final decimalIndex = _weightDecimal.clamp(0, 9);

    // Create controllers
    final wholeController = WheelPickerController(
      itemCount: maxWeight - minWeight + 1,
      initialIndex: wholeIndex,
    );

    final decimalController = WheelPickerController(
      itemCount: 10,
      initialIndex: decimalIndex,
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
            // Whole number wheel
            Expanded(
              flex: 2,
              child: WheelPicker(
                builder: (context, index) {
                  final value = minWeight + index;
                  final isSelected = value == _weightWhole;

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
                          ' kg',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.thirdColor, // Blue color for selected item
                          ),
                        ),
                    ],
                  );
                },
                controller: wholeController,
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
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _weightWhole = minWeight + index;
                    });
                  }
                },
              ),
            ),

            // Decimal wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) {
                  final value = index;
                  final isSelected = value == _weightDecimal;

                  return Text(
                    '.$value',
                    style: TextStyle(
                      fontSize: isSelected ? 22 : 20,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppColor.thirdColor // Blue color for selected item
                          : Colors.white70, // Light color for better visibility on dark background
                    ),
                  );
                },
                controller: decimalController,
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
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _weightDecimal = index;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImperialWeightPicker() {
    // Generate weight values for imperial (lbs)
    const int minWeight = 66;
    const int maxWeight = 330;

    // Ensure weight is within range
    if (_weightWhole < minWeight) _weightWhole = minWeight;
    if (_weightWhole > maxWeight) _weightWhole = maxWeight;

    // Calculate initial indices
    final wholeIndex = (_weightWhole - minWeight).clamp(0, maxWeight - minWeight);
    final decimalIndex = _weightDecimal.clamp(0, 9);

    // Create controllers
    final wholeController = WheelPickerController(
      itemCount: maxWeight - minWeight + 1,
      initialIndex: wholeIndex,
    );

    final decimalController = WheelPickerController(
      itemCount: 10,
      initialIndex: decimalIndex,
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
            // Whole number wheel
            Expanded(
              flex: 2,
              child: WheelPicker(
                builder: (context, index) {
                  final value = minWeight + index;
                  final isSelected = value == _weightWhole;

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
                          ' lbs',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.thirdColor, // Blue color for selected item
                          ),
                        ),
                    ],
                  );
                },
                controller: wholeController,
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
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _weightWhole = minWeight + index;
                    });
                  }
                },
              ),
            ),

            // Decimal wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) {
                  final value = index;
                  final isSelected = value == _weightDecimal;

                  return Text(
                    '.$value',
                    style: TextStyle(
                      fontSize: isSelected ? 22 : 20,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppColor.thirdColor // Blue color for selected item
                          : Colors.white70, // Light color for better visibility on dark background
                    ),
                  );
                },
                controller: decimalController,
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
                  if (!_isDisposed && mounted) {
                    setState(() {
                      _weightDecimal = index;
                    });
                  }
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
            context.l10n.weight,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Weight picker
        _buildWeightPicker(),

        const SizedBox(height: 16),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              haptic(HapticFeedbackType.success);
              _updateWeightFromWheelPicker();
              widget.onSaved(_weight);
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
