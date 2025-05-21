import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/language/language_manager.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Màn hình chọn ngôn ngữ toàn màn hình
class LanguageSelectorFullscreen extends StatefulWidget {
  /// Mã ngôn ngữ hiện tại
  final String currentLanguage;

  /// Callback khi ngôn ngữ được chọn
  final Function(String) onLanguageSelected;

  /// Constructor
  const LanguageSelectorFullscreen({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  /// Hiển thị màn hình chọn ngôn ngữ toàn màn hình
  static Future<void> show({
    required BuildContext context,
    required String currentLanguage,
    required Function(String) onLanguageSelected,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => LanguageSelectorFullscreen(
          currentLanguage: currentLanguage,
          onLanguageSelected: onLanguageSelected,
        ),
      ),
    );
  }

  @override
  State<LanguageSelectorFullscreen> createState() => _LanguageSelectorFullscreenState();
}

class _LanguageSelectorFullscreenState extends State<LanguageSelectorFullscreen> with HapticFeedbackMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: Text(
          context.l10n.changeLanguage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor.withAlpha(204), // 0.8 opacity
              AppColor.secondaryColor.withAlpha(179), // 0.7 opacity
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.l10n.changeLanguage,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  context.l10n.selectYourPreferredLanguage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildLanguageList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageList() {
    return FutureBuilder<List<LanguageModel>>(
      future: LanguageManager.getSupportedLanguages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final languages = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final isSelected = language.code == widget.currentLanguage;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isSelected
                    ? const BorderSide(color: AppColor.thirdColor, width: 2)
                    : BorderSide.none,
              ),
              color: isSelected
                  ? AppColor.thirdColor.withAlpha(51) // 0.2 opacity
                  : Colors.white.withAlpha(26), // 0.1 opacity
              child: InkWell(
                onTap: () {
                  haptic(HapticFeedbackType.selection);
                  widget.onLanguageSelected(language.code);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Hình ảnh cờ quốc gia
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          language.imagePath,
                          width: 40,
                          height: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.language,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tên ngôn ngữ
                      Expanded(
                        child: Text(
                          language.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Biểu tượng đã chọn
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
