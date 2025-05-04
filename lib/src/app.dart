import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/theme/app_theme.dart';
import 'package:water_mind/src/core/theme/providers/theme_provider.dart';

/// The main app widget that uses Riverpod for state management and localization.
class App extends ConsumerWidget {
  /// Creates a new [App] instance.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy router từ provider
    final router = ref.watch(routerProvider);

    // Lấy theme data từ provider
    final themeData = ref.watch(themeDataProvider);

    // Tạo theme dựa trên theme data
    final theme = AppTheme.createTheme(themeData);

    return MaterialApp.router(
      // Thiết lập theme cho ứng dụng
      theme: theme,
      // Thêm các delegate cho đa ngôn ngữ
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Định nghĩa các locale được hỗ trợ
      supportedLocales: AppLocalizations.supportedLocales,

      title: 'Water Mind',

      // Cấu hình router
      routerConfig: router.config(),
    );
  }
}
