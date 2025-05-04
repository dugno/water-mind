import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_mind/src/core/theme/app_theme_data.dart';

/// Provider cho theme repository
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return SharedPrefsThemeRepository();
});

/// Interface cho theme repository
abstract class ThemeRepository {
  /// Lấy theme đã lưu
  Future<AppThemeData?> getTheme();

  /// Lưu theme
  Future<void> saveTheme(AppThemeData themeData);
}

/// Triển khai theme repository sử dụng SharedPreferences
class SharedPrefsThemeRepository implements ThemeRepository {
  /// Key để lưu theme style
  static const String _themeStyleKey = 'theme_style';

  @override
  Future<AppThemeData?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(_themeStyleKey)) {
      return null;
    }
    
    final themeStyleIndex = prefs.getInt(_themeStyleKey) ?? 0;
    final themeStyle = AppThemeStyle.values[themeStyleIndex];
    
    return AppThemeData(themeStyle: themeStyle);
  }

  @override
  Future<void> saveTheme(AppThemeData themeData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeStyleKey, themeData.themeStyle.index);
  }
}
