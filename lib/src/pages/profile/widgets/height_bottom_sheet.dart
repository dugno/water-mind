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
      backgroundColor: AppColor.thirdColor,
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
    
    // Create items for the wheel picker
    final List<WheelPickerItem<int>> heightItems = List.generate(
      maxHeight - minHeight + 1,
      (index) => WheelPickerItem<int>(
        value: minHeight + index,
        text: '${minHeight + index} cm',
      ),
    );
    
    // Calculate initial index
    final initialIndex = (_heightWhole - minHeight).clamp(0, maxHeight - minHeight);
    
    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [heightItems],
        initialIndices: [initialIndex],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            _heightWhole = value as int;
          });
        },
        config: const WheelPickerConfig(
          height: 200,
          useHapticFeedback: true,
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
    
    // Create items for feet
    final List<WheelPickerItem<int>> feetItems = List.generate(
      maxFeet - minFeet + 1,
      (index) => WheelPickerItem<int>(
        value: minFeet + index,
        text: '${minFeet + index} ft',
      ),
    );
    
    // Create items for inches
    final List<WheelPickerItem<int>> inchesItems = List.generate(
      maxInches + 1,
      (index) => WheelPickerItem<int>(
        value: index,
        text: '$index in',
      ),
    );
    
    // Calculate initial indices
    final feetIndex = (_heightWhole - minFeet).clamp(0, maxFeet - minFeet);
    final inchesIndex = _heightDecimal.clamp(0, maxInches);
    
    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [feetItems, inchesItems],
        initialIndices: [feetIndex, inchesIndex],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            if (columnIndex == 0) {
              _heightWhole = value as int;
            } else {
              _heightDecimal = value as int;
            }
          });
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
    final heightUnit = widget.measureUnit == MeasureUnit.metric ? 'cm' : 'ft/in';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.height,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Current height display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.measureUnit == MeasureUnit.metric
                ? '${_heightWhole} cm'
                : '${_heightWhole} ft ${_heightDecimal} in',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Height picker
        _buildHeightPicker(),
        
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
                    _updateHeightFromWheelPicker();
                    widget.onSaved(_height);
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
