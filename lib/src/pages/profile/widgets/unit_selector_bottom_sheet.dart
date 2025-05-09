import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_config.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_item.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/widgets/wheel_picker.dart';

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
      backgroundColor: AppColor.thirdColor,
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
    // Create items for the wheel picker
    final List<WheelPickerItem<MeasureUnit>> unitItems = [
      WheelPickerItem<MeasureUnit>(
        value: MeasureUnit.metric,
        text: context.l10n.metric,
      ),
      WheelPickerItem<MeasureUnit>(
        value: MeasureUnit.imperial,
        text: context.l10n.imperial,
      ),
    ];

    // Find initial index
    int initialIndex = _selectedUnit == MeasureUnit.metric ? 0 : 1;

    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [unitItems],
        initialIndices: [initialIndex],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            _selectedUnit = value as MeasureUnit;
          });
        },
        config: const WheelPickerConfig(
          height: 200,
          useHapticFeedback: true,
          itemHeight: 50,
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
            context.l10n.units,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Current unit display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _selectedUnit == MeasureUnit.metric ? context.l10n.metric : context.l10n.imperial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Unit picker
        _buildUnitPicker(),

        const SizedBox(height: 24),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _selectedUnit == MeasureUnit.metric
                ? 'Metric: cm, kg, ml'
                : 'Imperial: in, lb, oz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    widget.onUnitChanged(_selectedUnit);
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
