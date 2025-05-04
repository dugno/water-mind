import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/theme/app_theme_data.dart';
import 'package:water_mind/src/core/theme/providers/theme_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Trang cài đặt theme cho ứng dụng
@RoutePage()
class ThemeSettingsPage extends ConsumerWidget {
  /// Tạo một instance [ThemeSettingsPage] mới
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy theme data hiện tại
    final themeData = ref.watch(themeDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.theme),
      ),
      body: ListView(
        children: [
          _buildThemeOption(
            context,
            ref,
            title: 'Blue Theme',
            style: AppThemeStyle.blue,
            currentStyle: themeData.themeStyle,
            color: Colors.blue,
          ),
          _buildThemeOption(
            context,
            ref,
            title: 'Green Theme',
            style: AppThemeStyle.green,
            currentStyle: themeData.themeStyle,
            color: Colors.green,
          ),
          _buildThemeOption(
            context,
            ref,
            title: 'Purple Theme',
            style: AppThemeStyle.purple,
            currentStyle: themeData.themeStyle,
            color: Colors.purple,
          ),
          _buildThemeOption(
            context,
            ref,
            title: 'Orange Theme',
            style: AppThemeStyle.orange,
            currentStyle: themeData.themeStyle,
            color: Colors.orange,
          ),
          _buildThemeOption(
            context,
            ref,
            title: 'Pink Theme',
            style: AppThemeStyle.pink,
            currentStyle: themeData.themeStyle,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  /// Tạo một tùy chọn theme
  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required AppThemeStyle style,
    required AppThemeStyle currentStyle,
    required Color color,
  }) {
    final isSelected = style == currentStyle;

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundColor: color,
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
      onTap: () {
        // Cập nhật theme khi người dùng chọn
        ref.read(themeDataProvider.notifier).setThemeStyle(style);
      },
    );
  }
}
