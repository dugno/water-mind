import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

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
      useGradientBackground: true,
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
    // Create a list of all gender values
    final List<Gender> genders = [
      Gender.male,
      Gender.female,
      Gender.pregnant,
      Gender.breastfeeding,
      Gender.other,
    ];

    // Find initial index
    int initialIndex = genders.indexOf(_gender);
    if (initialIndex < 0) initialIndex = 0;

    // Create controller
    final genderController = WheelPickerController(
      itemCount: genders.length,
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
            final gender = genders[index];
            final isSelected = gender == _gender;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getGenderIcon(gender),
                  color: isSelected ? AppColor.thirdColor : Colors.white70,
                  size: isSelected ? 24 : 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _getGenderText(gender),
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColor.thirdColor // Blue color for selected item
                        : Colors.white70, // Light color for better visibility on dark background
                  ),
                ),
              ],
            );
          },
          controller: genderController,
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
              _gender = genders[index];
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
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.l10n.gender,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Gender picker
        _buildGenderPicker(),

        const SizedBox(height: 16),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              haptic(HapticFeedbackType.success);
              widget.onSaved(_gender);
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
