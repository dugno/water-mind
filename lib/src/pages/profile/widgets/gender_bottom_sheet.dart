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

/// Bottom sheet for selecting gender
class GenderBottomSheet extends StatefulWidget {
  /// Initial gender
  final Gender? initialGender;

  /// Callback when gender is saved
  final Function(Gender) onSaved;

  /// Constructor
  const GenderBottomSheet({
    super.key,
    this.initialGender,
    required this.onSaved,
  });

  /// Show the gender bottom sheet
  static Future<void> show({
    required BuildContext context,
    Gender? initialGender,
    required Function(Gender) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      backgroundColor: Colors.white,
      maxHeightFactor: 0.6,
      child: GenderBottomSheet(
        initialGender: initialGender,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<GenderBottomSheet> createState() => _GenderBottomSheetState();
}

class _GenderBottomSheetState extends State<GenderBottomSheet> with HapticFeedbackMixin {
  late Gender _gender;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialGender ?? Gender.male;
  }

  IconData _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.male:
        return Icons.male;
      case Gender.female:
        return Icons.female;
      case Gender.pregnant:
        return Icons.pregnant_woman;
      case Gender.breastfeeding:
        return Icons.child_care;
      case Gender.other:
        return Icons.person;
    }
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

  Widget _buildGenderPicker() {
    // Create items for the wheel picker
    final List<WheelPickerItem<Gender>> genderItems = [
      WheelPickerItem<Gender>(
        value: Gender.male,
        text: '${_getGenderText(Gender.male)} (${Icons.male.codePoint.toRadixString(16)})',
      ),
      WheelPickerItem<Gender>(
        value: Gender.female,
        text: '${_getGenderText(Gender.female)} (${Icons.female.codePoint.toRadixString(16)})',
      ),
      WheelPickerItem<Gender>(
        value: Gender.pregnant,
        text: _getGenderText(Gender.pregnant),
      ),
      WheelPickerItem<Gender>(
        value: Gender.breastfeeding,
        text: _getGenderText(Gender.breastfeeding),
      ),
      WheelPickerItem<Gender>(
        value: Gender.other,
        text: _getGenderText(Gender.other),
      ),
    ];

    // Find initial index
    int initialIndex = 0;
    for (int i = 0; i < genderItems.length; i++) {
      if (genderItems[i].value == _gender) {
        initialIndex = i;
        break;
      }
    }

    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [genderItems],
        initialIndices: [initialIndex],
        onSelectedItemChanged: (columnIndex, itemIndex, value) {
          haptic(HapticFeedbackType.selection);
          setState(() {
            _gender = value as Gender;
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
            context.l10n.gender,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Current gender display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getGenderIcon(_gender),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                _getGenderText(_gender),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Gender picker
        _buildGenderPicker(),

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
                    widget.onSaved(_gender);
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
