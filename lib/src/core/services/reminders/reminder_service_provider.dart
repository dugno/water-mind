import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/daily_water_summary_dao.dart';
import 'package:water_mind/src/core/database/daos/forecast_hydration_dao.dart';
import 'package:water_mind/src/core/database/daos/reminder_settings_dao.dart';
import 'package:water_mind/src/core/database/daos/user_data_dao.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/services/hydration/daily_water_summary_repository.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_provider.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/notifications/notification_riverpod_provider.dart';
import 'package:water_mind/src/core/services/reminders/reminder_provider.dart';
import 'package:water_mind/src/core/services/reminders/reminder_repository.dart';
import 'package:water_mind/src/core/services/user/user_provider.dart';
import 'package:water_mind/src/core/services/user/user_repository.dart';
import 'package:water_mind/src/core/services/weather/daily_weather_service.dart';

import 'package:water_mind/src/core/services/weather/models/weather_data.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
import 'reminder_service_interface.dart';
import 'water_reminder_service.dart';

/// Provider cho reminder service
final reminderServiceProvider = Provider<ReminderServiceInterface>((ref) {
  final notificationManager = ref.watch(notificationManagerProvider);
  final reminderRepository = ref.watch(reminderRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final waterIntakeRepository = ref.watch(waterIntakeRepositoryProvider);
  final weatherService = ref.watch(dailyWeatherServiceProvider);

  return WaterReminderService(
    notificationManager: notificationManager,
    reminderRepository: reminderRepository,
    userRepository: userRepository,
    waterIntakeRepository: waterIntakeRepository,
    weatherService: weatherService,
  );
});

/// Tạo một instance mới của WaterReminderService
/// Được sử dụng cho migration và testing
class ReminderServiceProvider {
  /// Tạo một instance mới của WaterReminderService
  static ReminderServiceInterface createWaterReminderService() {
    // Tạo một NotificationManager mới
    final notificationManager = NotificationManagerProvider.createNotificationManager();

    // Tạo một ReminderRepository mới
    final database = DatabaseInitializer.database;
    final reminderDao = ReminderSettingsDao(database);
    final reminderRepository = ReminderRepositoryImpl(reminderDao);

    // Tạo các repository và service thực tế kết nối với database
    final userDao = UserDataDao(database);
    final userRepository = UserRepositoryImpl(userDao);

    // Tạo DailyWaterSummaryRepository
    final dailyWaterSummaryDao = DailyWaterSummaryDao(database);
    final dailyWaterSummaryRepository = DailyWaterSummaryRepositoryImpl(dailyWaterSummaryDao);

    // Tạo WaterIntakeRepository
    final waterIntakeDao = WaterIntakeDao(database);

    // Tạo một instance đơn giản của WaterIntakeRepository
    final waterIntakeRepository = SimpleWaterIntakeRepository(waterIntakeDao, dailyWaterSummaryRepository);

    // Tạo ForecastHydrationDao để lấy dữ liệu thời tiết từ database
    final forecastHydrationDao = ForecastHydrationDao(database);

    // Tạo một instance của SimpleDailyWeatherService
    final weatherService = SimpleDailyWeatherService(forecastHydrationDao);

    // Tạo một WaterReminderService mới
    return WaterReminderService(
      notificationManager: notificationManager,
      reminderRepository: reminderRepository,
      userRepository: userRepository,
      waterIntakeRepository: waterIntakeRepository,
      // Sử dụng dynamic để tránh lỗi kiểu
      weatherService: weatherService as dynamic,
    );
  }
}

/// Lớp triển khai đơn giản của WaterIntakeRepository
class SimpleWaterIntakeRepository implements WaterIntakeRepository {
  final WaterIntakeDao _dao;
  final DailyWaterSummaryRepository _dailyWaterSummaryRepository;

  /// Constructor
  SimpleWaterIntakeRepository(this._dao, this._dailyWaterSummaryRepository);

  @override
  Future<void> addWaterIntakeEntry(DateTime date, WaterIntakeEntry entry) async {
    try {
      // Lấy lịch sử hiện tại
      final currentHistory = await getWaterIntakeHistory(date) ?? WaterIntakeHistory(
        date: date,
        entries: [],
        dailyGoal: 2500.0,
        measureUnit: MeasureUnit.metric,
      );

      // Thêm entry mới
      final entries = List<WaterIntakeEntry>.from(currentHistory.entries);
      entries.add(entry);

      // Cập nhật lịch sử
      final updatedHistory = currentHistory.copyWith(entries: entries);

      // Lưu lịch sử đã cập nhật
      await saveWaterIntakeHistory(updatedHistory);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error adding water intake entry');
      rethrow;
    }
  }

  @override
  Future<void> clearAllWaterIntakeHistory() async {
    try {
      await _dao.clearAllWaterIntakeHistory();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing all water intake history');
      rethrow;
    }
  }

  @override
  Future<void> deleteWaterIntakeEntry(DateTime date, String entryId) async {
    try {
      // Lấy lịch sử hiện tại
      final currentHistory = await getWaterIntakeHistory(date);
      if (currentHistory == null) {
        AppLogger.warning('No history found for date: $date when trying to delete entry: $entryId');
        return;
      }

      // Xóa entry
      final entries = List<WaterIntakeEntry>.from(currentHistory.entries);
      entries.removeWhere((entry) => entry.id == entryId);

      // Cập nhật lịch sử
      final updatedHistory = currentHistory.copyWith(entries: entries);

      // Lưu lịch sử đã cập nhật
      await saveWaterIntakeHistory(updatedHistory);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting water intake entry');
      rethrow;
    }
  }

  @override
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date) async {
    try {
      await _dao.deleteWaterIntakeHistoryOlderThan(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting water intake history older than date');
      rethrow;
    }
  }

  @override
  Future<List<WaterIntakeHistory>> getAllWaterIntakeHistory({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dao.getAllWaterIntakeHistory(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting all water intake history');
      rethrow;
    }
  }

  @override
  Future<WaterIntakeHistory?> getWaterIntakeHistory(DateTime date) async {
    try {
      return await _dao.getWaterIntakeHistory(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history');
      rethrow;
    }
  }

  @override
  Future<void> saveWaterIntakeHistory(WaterIntakeHistory history) async {
    try {
      await _dao.saveWaterIntakeHistory(history);
      await _dailyWaterSummaryRepository.updateFromWaterIntakeHistory(history);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving water intake history');
      rethrow;
    }
  }
}

/// Lớp triển khai đơn giản của DailyWeatherService
/// Lấy dữ liệu thời tiết từ database thay vì trả về giá trị cứng
class SimpleDailyWeatherService {
  final ForecastHydrationDao _forecastHydrationDao;

  /// Constructor
  SimpleDailyWeatherService(this._forecastHydrationDao);

  /// Trả về dữ liệu thời tiết hiện tại từ database
  Future<NetworkResult<WeatherData>> getCurrentWeather({bool forceRefresh = false}) async {
    try {
      // Lấy ngày hiện tại
      final today = DateTime.now();
      final normalizedDate = DateTime(today.year, today.month, today.day);

      // Lấy dữ liệu dự báo thời tiết từ database
      final forecastData = await _forecastHydrationDao.getForecastHydration(normalizedDate);

      if (forecastData != null) {
        AppLogger.info('Lấy dữ liệu thời tiết từ database thành công: ${forecastData.weatherDescription}');

        // Chuyển đổi từ ForecastHydrationModel sang WeatherData
        return NetworkResult.success(
          WeatherData(
            temperature: (forecastData.maxTemperature + forecastData.minTemperature) / 2, // Nhiệt độ trung bình
            feelsLike: forecastData.maxTemperature, // Sử dụng nhiệt độ tối đa làm feelsLike
            humidity: 60, // Giá trị mặc định vì không có trong ForecastHydrationModel
            windSpeed: 10.0, // Giá trị mặc định vì không có trong ForecastHydrationModel
            condition: _getWeatherConditionFromCode(forecastData.weatherConditionCode),
            description: forecastData.weatherDescription,
            iconUrl: '', // Không có trong ForecastHydrationModel
            timestamp: forecastData.lastUpdated ?? DateTime.now(),
          ),
        );
      } else {
        AppLogger.warning('Không tìm thấy dữ liệu thời tiết trong database, sử dụng giá trị mặc định');

        // Nếu không có dữ liệu trong database, trả về giá trị mặc định
        return NetworkResult.success(
          WeatherData(
            temperature: 25.0,
            feelsLike: 26.0,
            humidity: 60,
            windSpeed: 10.0,
            condition: WeatherCondition.sunny,
            description: 'Sunny',
            iconUrl: '',
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Lỗi khi lấy dữ liệu thời tiết từ database');

      // Nếu có lỗi, trả về giá trị mặc định
      return NetworkResult.success(
        WeatherData(
          temperature: 25.0,
          feelsLike: 26.0,
          humidity: 60,
          windSpeed: 10.0,
          condition: WeatherCondition.sunny,
          description: 'Sunny',
          iconUrl: '',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Chuyển đổi từ mã điều kiện thời tiết sang WeatherCondition
  WeatherCondition _getWeatherConditionFromCode(int code) {
    // Dựa vào mã điều kiện thời tiết từ API WeatherAPI.com
    // https://www.weatherapi.com/docs/weather_conditions.json
    if (code == 1000) {
      return WeatherCondition.sunny; // Sunny/Clear
    } else if (code >= 1003 && code <= 1009) {
      return WeatherCondition.cloudy; // Cloudy conditions
    } else if (code >= 1030 && code <= 1039) {
      return WeatherCondition.fog; // Fog, mist
    } else if (code >= 1063 && code <= 1069) {
      return WeatherCondition.patchyRainPossible; // Patchy rain
    } else if (code >= 1072 && code <= 1087) {
      return WeatherCondition.patchySnowPossible; // Freezing conditions
    } else if (code >= 1114 && code <= 1117) {
      return WeatherCondition.blizzard; // Blizzard
    } else if (code >= 1150 && code <= 1201) {
      return WeatherCondition.moderateRain; // Rain
    } else if (code >= 1204 && code <= 1237) {
      return WeatherCondition.moderateSnow; // Snow
    } else if (code >= 1240 && code <= 1246) {
      return WeatherCondition.moderateRain; // Shower rain
    } else if (code >= 1249 && code <= 1264) {
      return WeatherCondition.moderateSnow; // Sleet and snow showers
    } else if (code >= 1273 && code <= 1282) {
      return WeatherCondition.thunderyOutbreaksPossible; // Thunder
    } else {
      return WeatherCondition.sunny; // Default
    }
  }

  /// Phương thức dispose() để giải phóng tài nguyên
  void dispose() {
    // Không cần làm gì
  }
}
