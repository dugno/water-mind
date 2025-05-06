import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Dialog for selecting app language
class LanguageSelector extends StatelessWidget {
  /// Current language code
  final String currentLanguage;
  
  /// Callback when a language is selected
  final Function(String) onLanguageSelected;

  /// Constructor
  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.changeLanguage),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'English',
              'en',
              'assets/images/language/united_kingdom.png',
            ),
            _buildLanguageOption(
              context,
              'Tiếng Việt',
              'vi',
              'assets/images/language/vietnam.png',
            ),
            _buildLanguageOption(
              context,
              '日本語',
              'ja',
              'assets/images/language/japan.png',
            ),
            _buildLanguageOption(
              context,
              '中文',
              'zh',
              'assets/images/language/china.png',
            ),
            _buildLanguageOption(
              context,
              'Română',
              'ro',
              'assets/images/language/romania.png',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String name,
    String code,
    String flagAsset,
  ) {
    final isSelected = currentLanguage == code;
    
    return ListTile(
      leading: Image.asset(
        flagAsset,
        width: 32,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.language, size: 24);
        },
      ),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        onLanguageSelected(code);
        Navigator.of(context).pop();
      },
    );
  }
}
