import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// Bottom sheet for selecting measurement units
class UnitSelectorBottomSheet extends StatefulWidget {
  /// Current measurement unit
  final MeasureUnit measureUnit;

  /// Callback when unit is changed
  final Function(MeasureUnit) onUnitChanged;

  /// Constructor
  const UnitSelectorBottomSheet({
    super.key,
    required this.measureUnit,
    required this.onUnitChanged,
  });

  /// Show the unit selector bottom sheet
  static Future<void> show({
    required BuildContext context,
    required MeasureUnit measureUnit,
    required Function(MeasureUnit) onUnitChanged,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.5,
      child: UnitSelectorBottomSheet(
        measureUnit: measureUnit,
        onUnitChanged: onUnitChanged,
      ),
    );
  }

  @override
  State<UnitSelectorBottomSheet> createState() => _UnitSelectorBottomSheetState();
}

class _UnitSelectorBottomSheetState extends State<UnitSelectorBottomSheet> with HapticFeedbackMixin {
  late MeasureUnit _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.measureUnit;
  }

  Widget _buildUnitPicker() {
    // Create a list of measure units
    final List<MeasureUnit> units = [
      MeasureUnit.metric,
      MeasureUnit.imperial,
    ];

    // Find initial index
    int initialIndex = _selectedUnit == MeasureUnit.metric ? 0 : 1;

    // Create controller
    final unitController = WheelPickerController(
      itemCount: units.length,
      initialIndex: initialIndex,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26), // 0.1 opacity
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 100,
        child: WheelPicker(
        builder: (context, index) {
          final unit = units[index];
          final isSelected = unit == _selectedUnit;
          final unitText = unit == MeasureUnit.metric ? context.l10n.metric : context.l10n.imperial;

          return Text(
            unitText,
            style: TextStyle(
              fontSize: isSelected ? 22 : 20,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColor.thirdColor // Blue color for selected item
                  : Colors.white70, // Light color for better visibility on dark background
            ),
          );
        },
        controller: unitController,
        selectedIndexColor: Colors.transparent,
        looping: false,
        style: const WheelPickerStyle(
          itemExtent: 50,
          squeeze: 1.0,
          diameterRatio: 1.5,
          magnification: 1.2,
          surroundingOpacity: 0.3,
        ),
        onIndexChanged: (index, _) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            _selectedUnit = units[index];
          });
        },
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
          child: Text(
            context.l10n.units,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _selectedUnit == MeasureUnit.metric
                ? 'Metric: cm, kg, ml'
                : 'Imperial: in, lb, oz',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        // Unit picker
        _buildUnitPicker(),

        const SizedBox(height: 8),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              haptic(HapticFeedbackType.success);
              widget.onUnitChanged(_selectedUnit);
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
