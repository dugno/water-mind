import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/theme/app_theme_data.dart';
import 'package:water_mind/src/ui/widgets/progress_bar/progress_bar_theme.dart';

/// Main theme class for the application
///
/// This class is responsible for creating and managing theme data
/// for different theme styles and modes.
class AppTheme {
  /// Private constructor to prevent instantiation
  const AppTheme._();

  /// Creates a light theme with the specified style
  static ThemeData lightTheme(AppThemeStyle style) {
    final baseTheme = ThemeData.light();
    final colorScheme = _getColorScheme(style, Brightness.light);

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      extensions: [
        _createProgressBarTheme(colorScheme),
      ],
    );
  }

  /// Creates a dark theme with the specified style
  static ThemeData darkTheme(AppThemeStyle style) {
    final baseTheme = ThemeData.dark();
    final colorScheme = _getColorScheme(style, Brightness.dark);

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      extensions: [
        _createProgressBarTheme(colorScheme),
      ],
    );
  }

  /// Tạo theme dựa trên dữ liệu theme hiện tại
  static ThemeData createTheme(AppThemeData themeData) {
    // Chúng ta sẽ sử dụng theme sáng cho tất cả các theme
    return lightTheme(themeData.themeStyle);
  }

  /// Lấy color scheme cho style và brightness được chỉ định
  static ColorScheme _getColorScheme(
      AppThemeStyle style, Brightness brightness) {
    switch (style) {
      case AppThemeStyle.blue:
        return brightness == Brightness.light
            ? const ColorScheme.light(
                primary: AppColor.primaryColor,
                secondary: AppColor.secondaryColor,
                tertiary: AppColor.thirdColor,
                surface: AppColor.fiveColor,
                surfaceTint: AppColor.fiveColor,
                error: Colors.red,
              )
            : const ColorScheme.dark(
                primary: AppColor.fourColor,
                secondary: AppColor.thirdColor,
                tertiary: AppColor.secondaryColor,
                surface: Color(0xFF121212),
                surfaceTint: Color(0xFF121212),
                error: Colors.red,
              );
      case AppThemeStyle.green:
        return brightness == Brightness.light
            ? const ColorScheme.light(
                primary: Color(0xFF2E7D32),
                secondary: Color(0xFF66BB6A),
                tertiary: Color(0xFFA5D6A7),
                surface: Color(0xFFF1F8E9),
              )
            : const ColorScheme.dark(
                primary: Color(0xFF81C784),
                secondary: Color(0xFF4CAF50),
                tertiary: Color(0xFF2E7D32),
                surface: Color(0xFF121212),
              );
      case AppThemeStyle.purple:
        return brightness == Brightness.light
            ? const ColorScheme.light(
                primary: Color(0xFF6A1B9A),
                secondary: Color(0xFF9C27B0),
                tertiary: Color(0xFFCE93D8),
                surface: Color(0xFFF3E5F5),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFBA68C8),
                secondary: Color(0xFF9C27B0),
                tertiary: Color(0xFF6A1B9A),
                surface: Color(0xFF121212),
              );
      case AppThemeStyle.orange:
        return brightness == Brightness.light
            ? const ColorScheme.light(
                primary: Color(0xFFE65100),
                secondary: Color(0xFFFF9800),
                tertiary: Color(0xFFFFB74D),
                surface: Color(0xFFFFF3E0),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFFFB74D),
                secondary: Color(0xFFFF9800),
                tertiary: Color(0xFFE65100),
                surface: Color(0xFF121212),
              );
      case AppThemeStyle.pink:
        return brightness == Brightness.light
            ? const ColorScheme.light(
                primary: Color(0xFFD81B60),
                secondary: Color(0xFFE91E63),
                tertiary: Color(0xFFF48FB1),
                surface: Color(0xFFFCE4EC),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFF48FB1),
                secondary: Color(0xFFE91E63),
                tertiary: Color(0xFFD81B60),
                surface: Color(0xFF121212),
              );
    }
  }

  /// Tạo theme cho progress bar dựa trên color scheme và AppColor
  static ProgressBarTheme _createProgressBarTheme(ColorScheme colorScheme) {
    return ProgressBarTheme(
      completedSegmentColor: AppColor.primaryColor,
      incompleteSegmentColor: AppColor.fiveColor,
      labelColor: Colors.black87,
      segmentWidth: 12,
      segmentHeight: 12,
      segmentSpacing: 8,
      segmentBorderRadius: BorderRadius.circular(6),
    );
  }
}
