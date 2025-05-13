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
      backgroundColor: AppColor.thirdColor,
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

    // Create items for the wheel picker
    final List<WheelPickerItem<int>> weightItems = List.generate(
      maxWeight - minWeight + 1,
      (index) => WheelPickerItem<int>(
        value: minWeight + index,
        text: '${minWeight + index} kg',
      ),
    );

    // Create items for decimal
    final List<WheelPickerItem<int>> decimalItems = List.generate(
      10,
      (index) => WheelPickerItem<int>(
        value: index,
        text: '.$index',
      ),
    );

    // Calculate initial index
    final initialIndex = (_weightWhole - minWeight).clamp(0, maxWeight - minWeight);

    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [weightItems, decimalItems],
        initialIndices: [initialIndex, _weightDecimal],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          if (!_isDisposed && mounted) {
            setState(() {
              if (columnIndex == 0) {
                _weightWhole = value as int;
              } else {
                _weightDecimal = value as int;
              }
            });
          }
        },
        config: const WheelPickerConfig(
          height: 200,
          useHapticFeedback: true,
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

    // Create items for the wheel picker
    final List<WheelPickerItem<int>> weightItems = List.generate(
      maxWeight - minWeight + 1,
      (index) => WheelPickerItem<int>(
        value: minWeight + index,
        text: '${minWeight + index} lbs',
      ),
    );

    // Create items for decimal
    final List<WheelPickerItem<int>> decimalItems = List.generate(
      10,
      (index) => WheelPickerItem<int>(
        value: index,
        text: '.$index',
      ),
    );

    // Calculate initial index
    final initialIndex = (_weightWhole - minWeight).clamp(0, maxWeight - minWeight);

    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [weightItems, decimalItems],
        initialIndices: [initialIndex, _weightDecimal],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          if (!_isDisposed && mounted) {
            setState(() {
              if (columnIndex == 0) {
                _weightWhole = value as int;
              } else {
                _weightDecimal = value as int;
              }
            });
          }
        },
        config: const WheelPickerConfig(
          height: 200,
          useHapticFeedback: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightUnit = widget.measureUnit == MeasureUnit.metric ? 'kg' : 'lbs';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.weight,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Current weight display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '$_weightWhole.$_weightDecimal $weightUnit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Weight picker
        _buildWeightPicker(),

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
                    _updateWeightFromWheelPicker();
                    widget.onSaved(_weight);
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
