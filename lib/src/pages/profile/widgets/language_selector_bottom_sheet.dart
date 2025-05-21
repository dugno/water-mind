import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/language/language_manager.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

/// Bottom sheet for selecting app language
class LanguageSelectorBottomSheet extends StatefulWidget {
  /// Current language code
  final String currentLanguage;

  /// Callback when a language is selected
  final Function(String) onLanguageSelected;

  /// Constructor
  const LanguageSelectorBottomSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  /// Show the language selector bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String currentLanguage,
    required Function(String) onLanguageSelected,
  }) {
    return BaseBottomSheet.show(
      context: context,
      useGradientBackground: true,
      maxHeightFactor: 0.6,
      child: LanguageSelectorBottomSheet(
        currentLanguage: currentLanguage,
        onLanguageSelected: onLanguageSelected,
      ),
    );
  }

  @override
  State<LanguageSelectorBottomSheet> createState() => _LanguageSelectorBottomSheetState();
}

class _LanguageSelectorBottomSheetState extends State<LanguageSelectorBottomSheet> with HapticFeedbackMixin {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  Widget _buildLanguagePicker() {
    return FutureBuilder<List<LanguageModel>>(
      future: LanguageManager.getSupportedLanguages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final languages = snapshot.data!;

        // Find initial index
        int initialIndex = languages.indexWhere((lang) => lang.code == _selectedLanguage);
        if (initialIndex < 0) initialIndex = 0;

        // Create controller
        final languageController = WheelPickerController(
          itemCount: languages.length,
          initialIndex: initialIndex,
        );

        return SizedBox(
          height: 200,
          child: WheelPicker(
            builder: (context, index) {
              final lang = languages[index];
              final isSelected = lang.code == _selectedLanguage;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flag image
                  Image.asset(
                    lang.imagePath,
                    width: 24,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.language,
                        size: 20,
                        color: isSelected ? AppColor.thirdColor : Colors.white70,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  // Language name
                  Text(
                    lang.name,
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
            controller: languageController,
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
                _selectedLanguage = languages[index].code;
              });
            },
          ),
        );
      },
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
            context.l10n.changeLanguage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Language picker
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26), // 0.1 opacity
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildLanguagePicker(),
        ),

        const SizedBox(height: 16),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              haptic(HapticFeedbackType.success);
              // Lưu ngôn ngữ đã chọn trước khi đóng bottom sheet
              final selectedLanguage = _selectedLanguage;
              Navigator.of(context).pop();
              // Gọi callback sau khi đã đóng bottom sheet
              widget.onLanguageSelected(selectedLanguage);
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
