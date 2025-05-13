import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart' as logger;

// Mock AppLogger
class MockLogger extends Mock implements logger.Logger {}

// Tạo một phiên bản cơ sở dữ liệu trong bộ nhớ cho việc kiểm thử
AppDatabase _createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

// Khởi tạo AppLogger một lần duy nhất
void _initializeAppLogger() {
  try {
    // Khởi tạo logger cho test
    AppLogger.initialize(false);

    // Tạo file log tạm thời
    final tempDir = Directory.systemTemp.createTempSync('water_mind_test');
    final tempFile = File('${tempDir.path}/test_log.txt');
    if (!tempFile.existsSync()) {
      tempFile.createSync();
    }
    AppLogger.logFile = tempFile;
  } catch (e) {
    // Bỏ qua lỗi nếu logger đã được khởi tạo
    print('Logger initialization error (can be ignored): $e');
  }
}

void main() {
  late AppDatabase database;

  setUpAll(() {
    _initializeAppLogger();
  });

  setUp(() {
    database = _createTestDatabase();
  });

  tearDown(() async {
    await database.close();
  });

  group('UserStreakTable', () {
    test('getUserStreak should return null when no streak exists', () async {
      // Act
      final result = await database.getUserStreak();

      // Assert
      expect(result, isNull);
    });

    test('saveUserStreak should insert new streak', () async {
      // Arrange
      final now = DateTime.now();
      final streak = UserStreakTableCompanion(
        id: const Value('user_streak'),
        currentStreak: const Value(1),
        longestStreak: const Value(1),
        lastActiveDate: Value(now),
        lastUpdated: Value(now),
      );

      // Act
      await database.saveUserStreak(streak);
      final result = await database.getUserStreak();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('user_streak'));
      expect(result.currentStreak, equals(1));
      expect(result.longestStreak, equals(1));
      expect(result.lastActiveDate, equals(now));
    });

    test('saveUserStreak should update existing streak', () async {
      // Arrange
      final now = DateTime.now();
      final initialStreak = UserStreakTableCompanion(
        id: const Value('user_streak'),
        currentStreak: const Value(1),
        longestStreak: const Value(1),
        lastActiveDate: Value(now),
        lastUpdated: Value(now),
      );

      await database.saveUserStreak(initialStreak);

      final updatedStreak = UserStreakTableCompanion(
        id: const Value('user_streak'),
        currentStreak: const Value(2),
        longestStreak: const Value(2),
        lastActiveDate: Value(now.add(const Duration(days: 1))),
        lastUpdated: Value(now.add(const Duration(days: 1))),
      );

      // Act
      await database.saveUserStreak(updatedStreak);
      final result = await database.getUserStreak();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('user_streak'));
      expect(result.currentStreak, equals(2));
      expect(result.longestStreak, equals(2));
      expect(result.lastActiveDate, equals(now.add(const Duration(days: 1))));
    });

    test('updateUserStreak should create new streak when none exists', () async {
      // Arrange
      final now = DateTime.now();

      // Act
      await database.updateUserStreak(now);
      final result = await database.getUserStreak();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('user_streak'));
      expect(result.currentStreak, equals(1));
      expect(result.longestStreak, equals(1));
      expect(result.lastActiveDate.day, equals(now.day));
      expect(result.lastActiveDate.month, equals(now.month));
      expect(result.lastActiveDate.year, equals(now.year));
    });

    test('updateUserStreak should increment streak for consecutive days', () async {
      // Arrange
      final day1 = DateTime(2023, 5, 10);
      final day2 = DateTime(2023, 5, 11); // Next day

      // Act - Day 1
      await database.updateUserStreak(day1);
      final result1 = await database.getUserStreak();

      // Assert - Day 1
      expect(result1!.currentStreak, equals(1));
      expect(result1.longestStreak, equals(1));

      // Act - Day 2
      await database.updateUserStreak(day2);
      final result2 = await database.getUserStreak();

      // Assert - Day 2
      expect(result2!.currentStreak, equals(2));
      expect(result2.longestStreak, equals(2));
    });

    test('updateUserStreak should reset streak for non-consecutive days', () async {
      // Arrange
      final day1 = DateTime(2023, 5, 10);
      final day3 = DateTime(2023, 5, 13); // 3 days later

      // Act - Day 1
      await database.updateUserStreak(day1);
      final result1 = await database.getUserStreak();

      // Assert - Day 1
      expect(result1!.currentStreak, equals(1));
      expect(result1.longestStreak, equals(1));

      // Act - Day 3
      await database.updateUserStreak(day3);
      final result2 = await database.getUserStreak();

      // Assert - Day 3 (streak reset)
      expect(result2!.currentStreak, equals(1));
      expect(result2.longestStreak, equals(1)); // Longest remains 1
    });

    test('updateUserStreak should maintain longest streak', () async {
      // Arrange
      final day1 = DateTime(2023, 5, 10);
      final day2 = DateTime(2023, 5, 11);
      final day3 = DateTime(2023, 5, 12);
      final day5 = DateTime(2023, 5, 14); // Skip a day

      // Act - Build a 3-day streak
      await database.updateUserStreak(day1);
      await database.updateUserStreak(day2);
      await database.updateUserStreak(day3);
      final result1 = await database.getUserStreak();

      // Assert - 3-day streak
      expect(result1!.currentStreak, equals(3));
      expect(result1.longestStreak, equals(3));

      // Act - Skip a day, breaking the streak
      await database.updateUserStreak(day5);
      final result2 = await database.getUserStreak();

      // Assert - Current streak reset, longest maintained
      expect(result2!.currentStreak, equals(1));
      expect(result2.longestStreak, equals(3)); // Longest remains 3
    });

    test('updateUserStreak should not change streak for same-day entries', () async {
      // Arrange
      final day1 = DateTime(2023, 5, 10, 8, 0); // Morning
      final day1Evening = DateTime(2023, 5, 10, 20, 0); // Evening same day

      // Act - Morning
      await database.updateUserStreak(day1);
      final result1 = await database.getUserStreak();

      // Assert - Morning
      expect(result1!.currentStreak, equals(1));
      expect(result1.longestStreak, equals(1));

      // Act - Evening same day
      await database.updateUserStreak(day1Evening);
      final result2 = await database.getUserStreak();

      // Assert - No change in streak
      expect(result2!.currentStreak, equals(1));
      expect(result2.longestStreak, equals(1));
    });
  });
}
