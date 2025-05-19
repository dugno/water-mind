import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';

class HeightWeightSegment extends StatefulWidget {
  final Function(double, double, MeasureUnit)? onHeightWeightSelected;
  final double? initialHeight;
  final double? initialWeight;
  final MeasureUnit? initialUnit;

  const HeightWeightSegment({
    super.key,
    this.onHeightWeightSelected,
    this.initialHeight,
    this.initialWeight,
    this.initialUnit,
  });

  @override
  State<HeightWeightSegment> createState() => _HeightWeightSegmentState();
}

class _HeightWeightSegmentState extends State<HeightWeightSegment>
    with HapticFeedbackMixin {
  late MeasureUnit _selectedUnit;

  // Height values
  late int _heightWhole;
  late int _heightDecimal;

  // Weight values
  late int _weightWhole;
  late int _weightDecimal;

  @override
  void initState() {
    super.initState();

    _selectedUnit = widget.initialUnit ?? MeasureUnit.metric;

    // Initialize with provided values or defaults
    double initialHeight = widget.initialHeight ??
        (_selectedUnit == MeasureUnit.metric ? 170.0 : 5.7);
    double initialWeight = widget.initialWeight ??
        (_selectedUnit == MeasureUnit.metric ? 70.0 : 154.0);

    // Set initial height values
    _heightWhole = initialHeight.floor();
    _heightDecimal = ((initialHeight - _heightWhole) * 10).round();

    // Set initial weight values
    _weightWhole = initialWeight.floor();
    _weightDecimal = ((initialWeight - _weightWhole) * 10).round();
  }

  void _onUnitChanged(MeasureUnit? unit) {
    if (unit == null || unit == _selectedUnit) return;

    // Get current values
    double height = _heightWhole + (_heightDecimal / 10);
    double weight = _weightWhole + (_weightDecimal / 10);

    if (_selectedUnit == MeasureUnit.metric && unit == MeasureUnit.imperial) {
      // Convert from metric to imperial
      height = height / 30.48; // cm to feet
      weight = weight * 2.20462; // kg to lbs
    } else if (_selectedUnit == MeasureUnit.imperial &&
        unit == MeasureUnit.metric) {
      // Convert from imperial to metric
      height = height * 30.48; // feet to cm
      weight = weight / 2.20462; // lbs to kg
    }

    setState(() {
      _selectedUnit = unit;

      // Update height values
      _heightWhole = height.floor();
      _heightDecimal = ((height - _heightWhole) * 10).round();

      // Update weight values
      _weightWhole = weight.floor();
      _weightDecimal = ((weight - _weightWhole) * 10).round();
    });

    _notifyHeightWeightChanged();
  }

  void _notifyHeightWeightChanged() {
    if (widget.onHeightWeightSelected != null) {
      final height = _heightWhole + (_heightDecimal / 10);
      final weight = _weightWhole + (_weightDecimal / 10);
      widget.onHeightWeightSelected!(height, weight, _selectedUnit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildUnitSelector(),
          const SizedBox(height: 24),
          Row(
            children: [
              // Height picker
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${context.l10n.height} (${_selectedUnit == MeasureUnit.metric ? 'cm' : 'ft'})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: _buildHeightPicker(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Weight picker
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${context.l10n.weight} (${_selectedUnit == MeasureUnit.metric ? 'kg' : 'lbs'})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: _buildWeightPicker(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Row(
      children: [
        // Metric option
        _buildUnitOption(
          label: context.l10n.metric,
          value: MeasureUnit.metric,
        ),
        const SizedBox(width: 16),
        // Imperial option
        _buildUnitOption(
          label: context.l10n.imperial,
          value: MeasureUnit.imperial,
        ),
      ],
    );
  }

  Widget _buildUnitOption({
    required String label,
    required MeasureUnit value,
  }) {
    final isSelected = _selectedUnit == value;

    return GestureDetector(
      onTap: () => _onUnitChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.thirdColor : Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.thirdColor : Colors.white30,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColor.thirdColor.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeightPicker() {
    if (_selectedUnit == MeasureUnit.metric) {
      return _buildMetricHeightPicker();
    } else {
      return _buildImperialHeightPicker();
    }
  }

  Widget _buildMetricHeightPicker() {
    // Generate height values for metric (cm)
    const int minHeight = 50;
    const int maxHeight = 250;
    const int heightItemCount = maxHeight - minHeight + 1;

    // Create controller for whole numbers
    final wholeNumbersController = WheelPickerController(
      itemCount: heightItemCount,
      initialIndex: _heightWhole - minHeight,
    );

    return Center(
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
                      : Colors.white70,   // Light color for better visibility on dark background
                ),
              ),
              if (isSelected)
                Text(
                  ' cm',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.thirdColor, // Blue color for selected item
                  ),
                ),
            ],
          );
        },
        controller: wholeNumbersController,
        selectedIndexColor: Colors.transparent, // Make the default selection indicator transparent
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
            _heightDecimal = 0; // Reset decimal to 0 since we're not showing it anymore
          });
          _notifyHeightWeightChanged();
        },
      ),
    );
  }

  Widget _buildImperialHeightPicker() {
    // For imperial, we need feet and inches
    // Feet range (typically 2-8 feet)
    const int minFeet = 2;
    const int maxFeet = 8;
    const int feetItemCount = maxFeet - minFeet + 1;

    // Inches range (0-11 inches)
    const int maxInches = 11;
    const int inchesItemCount = maxInches + 1;

    // Create controllers
    final feetController = WheelPickerController(
      itemCount: feetItemCount,
      initialIndex: _heightWhole - minFeet,
    );

    final inchesController = WheelPickerController(
      itemCount: inchesItemCount,
      initialIndex: _heightDecimal,
    );

    return Row(
      children: [
        // Feet wheel
        Expanded(
          child: Center(
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
                        fontSize: 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColor.thirdColor // Blue color for selected item
                            : Colors.white70,   // Light color for better visibility on dark background
                      ),
                    ),
                    if (isSelected)
                      const Text(
                        ' ft',
                        style: TextStyle(
                          fontSize: 20,
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
                _notifyHeightWeightChanged();
              },
            ),
          ),
        ),

        // Inches wheel
        Expanded(
          child: Center(
            child: WheelPicker(
              builder: (context, index) {
                final isSelected = index == _heightDecimal;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$index',
                      style: TextStyle(
                        fontSize: isSelected ? 22 : 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColor.thirdColor // Blue color for selected item
                            : Colors.white70,   // Light color for better visibility on dark background
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
                _notifyHeightWeightChanged();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightPicker() {
    // Generate weight whole number values based on unit
    final int minWeight = _selectedUnit == MeasureUnit.metric ? 20 : 40;
    final int maxWeight = _selectedUnit == MeasureUnit.metric ? 200 : 440;
    final int weightItemCount = maxWeight - minWeight + 1;
    final String unit = _selectedUnit == MeasureUnit.metric ? 'kg' : 'lbs';

    // Create controller for whole numbers
    final wholeNumbersController = WheelPickerController(
      itemCount: weightItemCount,
      initialIndex: _weightWhole - minWeight,
    );

    return Center(
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
                  fontSize: 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColor.thirdColor // Blue color for selected item
                      : Colors.white70,   // Light color for better visibility on dark background
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
        controller: wholeNumbersController,
        selectedIndexColor: Colors.transparent, // Make the default selection indicator transparent
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
            _weightWhole = minWeight + index;
            _weightDecimal = 0; // Reset decimal to 0 since we're not showing it anymore
          });
          _notifyHeightWeightChanged();
        },
      ),
    );
  }
}
