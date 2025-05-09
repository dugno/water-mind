import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
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

  // Language data
  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'English',
      'code': 'en',
      'flag': 'assets/images/language/united_kingdom.png',
    },
    {
      'name': 'Tiếng Việt',
      'code': 'vi',
      'flag': 'assets/images/language/vietnam.png',
    },
    {
      'name': '日本語',
      'code': 'ja',
      'flag': 'assets/images/language/japan.png',
    },
    {
      'name': '中文',
      'code': 'zh',
      'flag': 'assets/images/language/china.png',
    },
    {
      'name': 'Română',
      'code': 'ro',
      'flag': 'assets/images/language/romania.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  Widget _buildLanguagePicker() {
    // Create items for the wheel picker
    final List<WheelPickerItem<String>> languageItems = _languages.map((lang) {
      return WheelPickerItem<String>(
        value: lang['code'] as String,
        text: lang['name'] as String,
      );
    }).toList();

    // Find initial index
    int initialIndex = 0;
    for (int i = 0; i < _languages.length; i++) {
      if (_languages[i]['code'] == _selectedLanguage) {
        initialIndex = i;
        break;
      }
    }

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
  }

  String _getLanguageName(String code) {
    for (final lang in _languages) {
      if (lang['code'] == code) {
        return lang['name'] as String;
      }
    }
    return 'Unknown';
  }

  String _getLanguageFlag(String code) {
    for (final lang in _languages) {
      if (lang['code'] == code) {
        return lang['flag'] as String;
      }
    }
    return '';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _getLanguageFlag(_selectedLanguage),
                width: 32,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.language, size: 24, color: Colors.white);
                },
              ),
              const SizedBox(width: 8),
              Text(
                _getLanguageName(_selectedLanguage),
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
