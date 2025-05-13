import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/user_streak_model.dart';
import 'package:water_mind/src/core/services/streak/streak_provider.dart';
import 'package:water_mind/src/ui/widgets/streak/streak_display_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  // Helper function để tạo widget test
  Widget createWidgetUnderTest({
    required Future<UserStreakModel?> userStreakFuture,
    required Future<bool> hasTodayStreakFuture,
  }) {
    return ProviderScope(
      overrides: [
        userStreakProvider.overrideWith((_) => userStreakFuture),
        hasTodayStreakProvider.overrideWith((_) => hasTodayStreakFuture),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StreakDisplayWidget(),
        ),
      ),
    );
  }

  group('StreakDisplayWidget', () {
    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      // Tạo một Completer để kiểm soát Future
      final userStreakCompleter = Completer<UserStreakModel?>();
      final hasTodayStreakCompleter = Completer<bool>();

      // Futures này sẽ không hoàn thành trong quá trình test
      final userStreakFuture = userStreakCompleter.future;
      final hasTodayStreakFuture = hasTodayStreakCompleter.future;

      // Render widget
      await tester.pumpWidget(
        createWidgetUnderTest(
          userStreakFuture: userStreakFuture,
          hasTodayStreakFuture: hasTodayStreakFuture,
        ),
      );

      // Verify loading indicator hiển thị
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Hoàn thành Future để tránh lỗi Timer
      userStreakCompleter.complete(null);
      hasTodayStreakCompleter.complete(false);
      await tester.pumpAndSettle();
    });

    testWidgets('shows streak info when data is available', (WidgetTester tester) async {
      // Tạo dữ liệu test
      final streak = UserStreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime.now(),
      );

      // Render widget với dữ liệu có sẵn
      await tester.pumpWidget(
        createWidgetUnderTest(
          userStreakFuture: Future.value(streak),
          hasTodayStreakFuture: Future.value(true),
        ),
      );

      // Đợi để Future hoàn thành và UI cập nhật
      await tester.pump();

      // Verify thông tin streak hiển thị đúng
      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('10 days'), findsOneWidget);
    });

    testWidgets('shows no streak message when streak is null', (WidgetTester tester) async {
      // Render widget với streak là null
      await tester.pumpWidget(
        createWidgetUnderTest(
          userStreakFuture: Future.value(null),
          hasTodayStreakFuture: Future.value(false),
        ),
      );

      // Đợi để Future hoàn thành và UI cập nhật
      await tester.pump();

      // Verify thông báo "no streak" hiển thị
      expect(find.text('No streak yet'), findsOneWidget);
      expect(find.text('Drink water today to start your streak!'), findsOneWidget);
    });

    testWidgets('shows warning when no streak today', (WidgetTester tester) async {
      // Tạo dữ liệu test với streak nhưng chưa uống nước hôm nay
      final streak = UserStreakModel(
        currentStreak: 7,
        longestStreak: 15,
        lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Render widget
      await tester.pumpWidget(
        createWidgetUnderTest(
          userStreakFuture: Future.value(streak),
          hasTodayStreakFuture: Future.value(false), // Chưa uống nước hôm nay
        ),
      );

      // Đợi để Future hoàn thành và UI cập nhật
      await tester.pump();

      // Verify thông tin streak hiển thị đúng
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('15 days'), findsOneWidget);

      // Verify cảnh báo hiển thị
      expect(find.text('Drink today!'), findsOneWidget);
    });
  });
}
