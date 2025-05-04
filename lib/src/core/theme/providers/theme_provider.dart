import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/theme/app_theme_data.dart';
import 'package:water_mind/src/core/theme/repositories/theme_repository.dart';

/// Provider cho dữ liệu theme hiện tại
final themeDataProvider = StateNotifierProvider<ThemeNotifier, AppThemeData>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return ThemeNotifier(repository);
});

/// Notifier để quản lý trạng thái theme
class ThemeNotifier extends StateNotifier<AppThemeData> {
  /// Repository để lưu trữ theme
  final ThemeRepository _repository;

  /// Tạo một instance [ThemeNotifier] mới
  ThemeNotifier(this._repository) : super(AppThemeData.defaultTheme) {
    _loadTheme();
  }

  /// Tải theme từ repository
  Future<void> _loadTheme() async {
    final themeData = await _repository.getTheme();
    if (themeData != null) {
      state = themeData;
    }
  }

  /// Cập nhật theme style
  Future<void> setThemeStyle(AppThemeStyle style) async {
    final newTheme = state.copyWith(themeStyle: style);
    state = newTheme;
    await _repository.saveTheme(newTheme);
  }
}
