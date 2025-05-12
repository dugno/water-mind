import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/language/language_manager.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_config.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_item.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/widgets/wheel_picker.dart';

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
      backgroundColor: AppColor.thirdColor,
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

        // Create items for the wheel picker with custom widgets that include flag images
        final List<WheelPickerItem<String>> languageItems = languages.map((lang) {
          return WheelPickerItem<String>(
            value: lang.code,
            text: lang.name, // Vẫn giữ text cho tương thích ngược
            widget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hình ảnh cờ quốc gia
                Image.asset(
                  lang.imagePath,
                  width: 24,
                  height: 18,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.language, size: 20, color: Colors.white);
                  },
                ),
                const SizedBox(width: 12),
                // Tên ngôn ngữ
                Text(
                  lang.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();

        // Find initial index
        int initialIndex = languages.indexWhere((lang) => lang.code == _selectedLanguage);
        if (initialIndex < 0) initialIndex = 0;

        return SizedBox(
          height: 200,
          child: WheelPicker(
            columns: [languageItems],
            initialIndices: [initialIndex],
            onSelectedItemChanged: (columnIndex, itemIndex, value) {
              haptic(HapticFeedbackType.selection);
              setState(() {
                _selectedLanguage = value as String;
              });
            },
            config: const WheelPickerConfig(
              height: 200,
              useHapticFeedback: true,
              itemHeight: 50,
            ),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Current language display
        FutureBuilder<LanguageModel?>(
          future: LanguageManager.getLanguageByCode(_selectedLanguage),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final language = snapshot.data;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    language?.imagePath ?? '',
                    width: 32,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.language, size: 24, color: Colors.white);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    language?.name ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Language picker
        _buildLanguagePicker(),

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
                    widget.onLanguageSelected(_selectedLanguage);
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
