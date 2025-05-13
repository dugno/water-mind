import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:water_mind/src/core/database/daos/user_streak_dao.dart';
import 'package:water_mind/src/core/models/user_streak_model.dart';
import 'package:water_mind/src/core/services/streak/streak_service.dart';

// Tạo mock classes
@GenerateMocks([UserStreakDao])
import 'streak_service_test.mocks.dart';

void main() {
  late StreakService streakService;
  late MockUserStreakDao mockUserStreakDao;

  setUp(() {
    mockUserStreakDao = MockUserStreakDao();
    streakService = StreakServiceImpl(mockUserStreakDao);
  });

  group('StreakService', () {
    test('getUserStreak should return streak from DAO', () async {
      // Arrange
      final expectedStreak = UserStreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime(2023, 5, 10),
      );
      when(mockUserStreakDao.getUserStreak()).thenAnswer((_) async => expectedStreak);

      // Act
      final result = await streakService.getUserStreak();

      // Assert
      expect(result, equals(expectedStreak));
      verify(mockUserStreakDao.getUserStreak()).called(1);
    });

    test('getUserStreak should return null when DAO returns null', () async {
      // Arrange
      when(mockUserStreakDao.getUserStreak()).thenAnswer((_) async => null);

      // Act
      final result = await streakService.getUserStreak();

      // Assert
      expect(result, isNull);
      verify(mockUserStreakDao.getUserStreak()).called(1);
    });

    test('updateUserStreak should call DAO updateUserStreak', () async {
      // Arrange
      final activityDate = DateTime(2023, 5, 10);
      when(mockUserStreakDao.updateUserStreak(any)).thenAnswer((_) async {});

      // Act
      await streakService.updateUserStreak(activityDate);

      // Assert
      verify(mockUserStreakDao.updateUserStreak(activityDate)).called(1);
    });

    test('hasStreakToday should return true when last active date is today', () async {
      // Arrange
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      
      final streak = UserStreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: normalizedToday,
      );
      
      when(mockUserStreakDao.getUserStreak()).thenAnswer((_) async => streak);

      // Act
      final result = await streakService.hasStreakToday();

      // Assert
      expect(result, isTrue);
      verify(mockUserStreakDao.getUserStreak()).called(1);
    });

    test('hasStreakToday should return false when last active date is not today', () async {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final normalizedYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      final streak = UserStreakModel(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: normalizedYesterday,
      );
      
      when(mockUserStreakDao.getUserStreak()).thenAnswer((_) async => streak);

      // Act
      final result = await streakService.hasStreakToday();

      // Assert
      expect(result, isFalse);
      verify(mockUserStreakDao.getUserStreak()).called(1);
    });

    test('hasStreakToday should return false when streak is null', () async {
      // Arrange
      when(mockUserStreakDao.getUserStreak()).thenAnswer((_) async => null);

      // Act
      final result = await streakService.hasStreakToday();

      // Assert
      expect(result, isFalse);
      verify(mockUserStreakDao.getUserStreak()).called(1);
    });
  });
}
