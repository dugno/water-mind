import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Dialog for editing physical attributes
class PhysicalAttributesDialog extends StatefulWidget {
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
  const PhysicalAttributesDialog({
    super.key,
    this.initialGender,
    this.initialHeight,
    this.initialWeight,
    required this.measureUnit,
    required this.onSaved,
  });

  @override
  State<PhysicalAttributesDialog> createState() => _PhysicalAttributesDialogState();
}

class _PhysicalAttributesDialogState extends State<PhysicalAttributesDialog> {
  late Gender _gender;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late double _height;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialGender ?? Gender.male;
    _height = widget.initialHeight ?? (widget.measureUnit == MeasureUnit.metric ? 170 : 67);
    _weight = widget.initialWeight ?? (widget.measureUnit == MeasureUnit.metric ? 70 : 154);

    _heightController = TextEditingController(text: _height.toString());
    _weightController = TextEditingController(text: _weight.toString());
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Build a chip for gender selection
  Widget _buildGenderChip(Gender gender) {
    final isSelected = _gender == gender;

    return FilterChip(
      label: Text(gender.getString(context)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _gender = gender;
          });
        }
      },
      avatar: Icon(
        gender == Gender.pregnant
            ? Icons.pregnant_woman
            : gender == Gender.breastfeeding
                ? Icons.child_care
                : Icons.person,
        size: 18,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final heightUnit = widget.measureUnit == MeasureUnit.metric ? 'cm' : 'in';
    final weightUnit = widget.measureUnit == MeasureUnit.metric ? 'kg' : 'lb';

    return AlertDialog(
      title: Text(context.l10n.physicalAttributes),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gender selection
            Text(
              context.l10n.gender,
              style: Theme.of(context).textTheme.titleMedium,
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
            const SizedBox(height: 16),

            // Height input
            Text(
              context.l10n.height,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.height,
                      suffixText: heightUnit,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _height = double.parse(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            // Height slider
            Slider(
              value: _height,
              min: widget.measureUnit == MeasureUnit.metric ? 100 : 39,
              max: widget.measureUnit == MeasureUnit.metric ? 220 : 87,
              divisions: widget.measureUnit == MeasureUnit.metric ? 120 : 48,
              label: '${_height.toStringAsFixed(1)} $heightUnit',
              onChanged: (value) {
                setState(() {
                  _height = value;
                  _heightController.text = value.toStringAsFixed(1);
                });
              },
            ),
            const SizedBox(height: 16),

            // Weight input
            Text(
              context.l10n.weight,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.weight,
                      suffixText: weightUnit,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _weight = double.parse(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            // Weight slider
            Slider(
              value: _weight,
              min: widget.measureUnit == MeasureUnit.metric ? 30 : 66,
              max: widget.measureUnit == MeasureUnit.metric ? 150 : 330,
              divisions: widget.measureUnit == MeasureUnit.metric ? 120 : 264,
              label: '${_weight.toStringAsFixed(1)} $weightUnit',
              onChanged: (value) {
                setState(() {
                  _weight = value;
                  _weightController.text = value.toStringAsFixed(1);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            widget.onSaved(_gender, _height, _weight);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
