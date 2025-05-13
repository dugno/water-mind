import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/database/daos/user_streak_dao.dart';
import 'package:water_mind/src/core/models/user_streak_model.dart';
import 'package:drift/drift.dart' hide isNull;

// Tạo mock classes
@GenerateMocks([AppDatabase])
import 'user_streak_dao_test.mocks.dart';

void main() {
  late UserStreakDao userStreakDao;
  late MockAppDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockAppDatabase();
    userStreakDao = UserStreakDao(mockDatabase);
  });

  group('UserStreakDao', () {
    test('modelToCompanion should convert UserStreakModel to UserStreakTableCompanion', () {
      // Arrange
      final model = UserStreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime(2023, 5, 10),
      );

      // Act
      final companion = userStreakDao.modelToCompanion(model);

      // Assert
      expect(companion.id.value, equals('user_streak'));
      expect(companion.currentStreak.value, equals(5));
      expect(companion.longestStreak.value, equals(10));
      expect(companion.lastActiveDate.value, equals(model.lastActiveDate));
    });

    test('dataToModel should convert UserStreakTableData to UserStreakModel', () {
      // Arrange
      final data = UserStreakTableData(
        id: 'user_streak',
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime(2023, 5, 10),
        lastUpdated: DateTime(2023, 5, 10, 12, 0),
      );

      // Act
      final model = userStreakDao.dataToModel(data);

      // Assert
      expect(model.currentStreak, equals(5));
      expect(model.longestStreak, equals(10));
      expect(model.lastActiveDate, equals(data.lastActiveDate));
    });

    test('getUserStreak should call database getUserStreak', () async {
      // Arrange
      final data = UserStreakTableData(
        id: 'user_streak',
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime(2023, 5, 10),
        lastUpdated: DateTime(2023, 5, 10, 12, 0),
      );

      when(mockDatabase.getUserStreak()).thenAnswer((_) async => data);

      // Act
      final result = await userStreakDao.getUserStreak();

      // Assert
      expect(result!.currentStreak, equals(5));
      expect(result.longestStreak, equals(10));
      expect(result.lastActiveDate, equals(data.lastActiveDate));
      verify(mockDatabase.getUserStreak()).called(1);
    });

    test('getUserStreak should return null when database returns null', () async {
      // Arrange
      when(mockDatabase.getUserStreak()).thenAnswer((_) async => null);

      // Act
      final result = await userStreakDao.getUserStreak();

      // Assert
      expect(result, isNull);
      verify(mockDatabase.getUserStreak()).called(1);
    });

    test('saveUserStreak should call database saveUserStreak', () async {
      // Arrange
      final model = UserStreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime(2023, 5, 10),
      );

      when(mockDatabase.saveUserStreak(any)).thenAnswer((_) async {});

      // Act
      await userStreakDao.saveUserStreak(model);

      // Assert
      verify(mockDatabase.saveUserStreak(any)).called(1);
    });

    test('updateUserStreak should call database updateUserStreak', () async {
      // Arrange
      final activityDate = DateTime(2023, 5, 10);
      when(mockDatabase.updateUserStreak(any)).thenAnswer((_) async {});

      // Act
      await userStreakDao.updateUserStreak(activityDate);

      // Assert
      verify(mockDatabase.updateUserStreak(activityDate)).called(1);
    });
  });
}
