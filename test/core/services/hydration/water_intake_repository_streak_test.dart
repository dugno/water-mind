import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_change_notifier.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/streak/streak_service.dart';
import 'package:water_mind/src/core/services/streak/streak_provider.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:logger/logger.dart' as logger;

// Tạo mock classes
@GenerateMocks([WaterIntakeDao, StreakService, Ref])
import 'water_intake_repository_streak_test.mocks.dart';

// Cung cấp dummy value cho WaterIntakeChangeNotifier
void provideDummyValue<T>(T value) => provideDummy<T>(value);

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
  // Cung cấp dummy value cho WaterIntakeChangeNotifier và StreakService
  provideDummyValue<WaterIntakeChangeNotifier>(WaterIntakeChangeNotifier());
  provideDummyValue<StreakService>(MockStreakService());

  // Khởi tạo AppLogger
  setUpAll(() {
    _initializeAppLogger();
  });
  late WaterIntakeRepository repository;
  late MockWaterIntakeDao mockDao;
  late MockStreakService mockStreakService;
  late MockRef mockRef;
  late ProviderContainer container;

  setUp(() {
    mockDao = MockWaterIntakeDao();
    mockStreakService = MockStreakService();
    mockRef = MockRef();

    // Tạo ProviderContainer thật để sử dụng với các provider
    container = ProviderContainer(
      overrides: [
        waterIntakeChangeNotifierProvider.overrideWith(
          (ref) => WaterIntakeChangeNotifier(),
        ),
      ],
    );

    // Giả lập việc đọc provider từ ref
    when(mockRef.read(waterIntakeChangeNotifierProvider.notifier))
        .thenReturn(container.read(waterIntakeChangeNotifierProvider.notifier));

    repository = DriftWaterIntakeRepository(mockDao, mockRef);
  });

  tearDown(() {
    container.dispose();
  });

  group('WaterIntakeRepository with Streak', () {
    test('addWaterIntakeEntry should update streak', () async {
      // Arrange
      final date = DateTime(2023, 5, 10);
      final entry = WaterIntakeEntry(
        id: '123',
        amount: 250,
        timestamp: DateTime(2023, 5, 10, 12, 0),
        drinkType: DrinkTypes.water,
      );

      // Giả lập các phương thức của DAO
      final mockHistory = WaterIntakeHistory(
        date: date,
        entries: [entry],
        dailyGoal: 2500,
        measureUnit: MeasureUnit.metric,
      );
      when(mockDao.addWaterIntakeEntry(date, entry)).thenAnswer((_) async => mockHistory);

      // Giả lập việc đọc streakServiceProvider từ ref
      when(mockRef.read(any)).thenReturn(mockStreakService);

      // Giả lập phương thức updateUserStreak của StreakService
      when(mockStreakService.updateUserStreak(date)).thenAnswer((_) async {});

      // Act
      await repository.addWaterIntakeEntry(date, entry);

      // Assert
      verify(mockDao.addWaterIntakeEntry(date, entry)).called(1);
      verify(mockStreakService.updateUserStreak(date)).called(1);
    });

    test('addWaterIntakeEntry should handle errors', () async {
      // Arrange
      final date = DateTime(2023, 5, 10);
      final entry = WaterIntakeEntry(
        id: '123',
        amount: 250,
        timestamp: DateTime(2023, 5, 10, 12, 0),
        drinkType: DrinkTypes.water,
      );

      // Giả lập lỗi từ DAO
      when(mockDao.addWaterIntakeEntry(date, entry)).thenThrow(Exception('Database error'));

      // Giả lập việc đọc streakServiceProvider từ ref
      when(mockRef.read(any)).thenReturn(mockStreakService);

      // Act & Assert
      expect(() => repository.addWaterIntakeEntry(date, entry), throwsException);
      verifyNever(mockStreakService.updateUserStreak(date));
    });
  });
}
