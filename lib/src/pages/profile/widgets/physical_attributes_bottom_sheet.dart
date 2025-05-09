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

/// Bottom sheet for editing physical attributes
class PhysicalAttributesBottomSheet extends StatefulWidget {
  /// Initial gender
  final Gender? initialGender;

  /// Initial height
  final double? initialHeight;

  /// Initial weight
  final double? initialWeight;

  /// Measurement unit
  final MeasureUnit measureUnit;

  /// Callback when values are saved
  final Function(Gender, double, double) onSaved;

  /// Constructor
  const PhysicalAttributesBottomSheet({
    super.key,
    this.initialGender,
    this.initialHeight,
    this.initialWeight,
    required this.measureUnit,
    required this.onSaved,
  });

  /// Show the physical attributes bottom sheet
  static Future<void> show({
    required BuildContext context,
    Gender? initialGender,
    double? initialHeight,
    double? initialWeight,
    required MeasureUnit measureUnit,
    required Function(Gender, double, double) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      backgroundColor: AppColor.thirdColor,
      maxHeightFactor: 0.8,
      child: PhysicalAttributesBottomSheet(
        initialGender: initialGender,
        initialHeight: initialHeight,
        initialWeight: initialWeight,
        measureUnit: measureUnit,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<PhysicalAttributesBottomSheet> createState() => _PhysicalAttributesBottomSheetState();
}

class _PhysicalAttributesBottomSheetState extends State<PhysicalAttributesBottomSheet> with HapticFeedbackMixin {
  late Gender _gender;
  late double _height;
  late double _weight;

  // For wheel pickers
  late int _heightWhole;
  late int _heightDecimal;
  late int _weightWhole;
  late int _weightDecimal;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialGender ?? Gender.male;
    _height = widget.initialHeight ?? (widget.measureUnit == MeasureUnit.metric ? 170 : 67);
    _weight = widget.initialWeight ?? (widget.measureUnit == MeasureUnit.metric ? 70 : 154);

    // Initialize wheel picker values
    _initializeWheelPickerValues();
  }

  void _initializeWheelPickerValues() {
    if (widget.measureUnit == MeasureUnit.metric) {
      _heightWhole = _height.toInt();
      _heightDecimal = ((_height - _heightWhole) * 10).round();
      _weightWhole = _weight.toInt();
      _weightDecimal = ((_weight - _weightWhole) * 10).round();
    } else {
      // For imperial, height is in inches
      _heightWhole = (_height / 12).floor(); // Feet
      _heightDecimal = (_height % 12).round(); // Inches
      _weightWhole = _weight.toInt();
      _weightDecimal = ((_weight - _weightWhole) * 10).round();
    }
  }

  void _updateHeightFromWheelPicker() {
    if (widget.measureUnit == MeasureUnit.metric) {
      _height = _heightWhole + (_heightDecimal / 10);
    } else {
      _height = (_heightWhole * 12.0) + _heightDecimal.toDouble();
    }
  }

  void _updateWeightFromWheelPicker() {
    _weight = _weightWhole + (_weightDecimal / 10);
  }

  Widget _buildGenderChip(Gender gender) {
    final isSelected = _gender == gender;
    return FilterChip(
      selected: isSelected,
      label: Text(_getGenderText(gender)),
      onSelected: (selected) {
        haptic(HapticFeedbackType.selection);
        setState(() {
          _gender = selected ? gender : Gender.male;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return context.l10n.male;
      case Gender.female:
        return context.l10n.female;
      case Gender.pregnant:
        return context.l10n.pregnant;
      case Gender.breastfeeding:
        return context.l10n.breastfeeding;
      case Gender.other:
        return context.l10n.other;
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
      height: 150,
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
          height: 150,
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
      height: 150,
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
          height: 150,
          useHapticFeedback: true,
        ),
      ),
    );
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

    // Calculate initial index
    final initialIndex = (_weightWhole - minWeight).clamp(0, maxWeight - minWeight);

    return SizedBox(
      height: 150,
      child: WheelPicker(
        columns: [weightItems],
        initialIndices: [initialIndex],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            _weightWhole = value as int;
          });
        },
        config: const WheelPickerConfig(
          height: 150,
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

    // Calculate initial index
    final initialIndex = (_weightWhole - minWeight).clamp(0, maxWeight - minWeight);

    return SizedBox(
      height: 150,
      child: WheelPicker(
        columns: [weightItems],
        initialIndices: [initialIndex],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            _weightWhole = value as int;
          });
        },
        config: const WheelPickerConfig(
          height: 150,
          useHapticFeedback: true,
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
            context.l10n.physicalAttributes,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Gender selection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.gender,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Main gender options
              SegmentedButton<Gender>(
                segments: [
                  ButtonSegment<Gender>(
                    value: Gender.male,
                    label: Text(context.l10n.male),
                    icon: const Icon(Icons.male),
                  ),
                  ButtonSegment<Gender>(
                    value: Gender.female,
                    label: Text(context.l10n.female),
                    icon: const Icon(Icons.female),
                  ),
                ],
                selected: {_gender == Gender.male || _gender == Gender.female ? _gender : Gender.male},
                onSelectionChanged: (Set<Gender> selection) {
                  if (selection.isNotEmpty) {
                    haptic(HapticFeedbackType.selection);
                    setState(() {
                      _gender = selection.first;
                    });
                  }
                },
              ),

              const SizedBox(height: 8),

              // Additional gender options
              Wrap(
                spacing: 8,
                children: [
                  _buildGenderChip(Gender.pregnant),
                  _buildGenderChip(Gender.breastfeeding),
                  _buildGenderChip(Gender.other),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Height picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.height,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _buildHeightPicker(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Weight picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.weight,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _buildWeightPicker(),
            ],
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
                    _updateHeightFromWheelPicker();
                    _updateWeightFromWheelPicker();
                    widget.onSaved(_gender, _height, _weight);
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