import 'package:water_mind/src/core/database/daos/user_data_dao.dart';
import 'package:water_mind/src/core/models/forecast_hydration_model.dart';
import 'package:water_mind/src/core/network/repositories/weather_repository_v2.dart';
import 'package:water_mind/src/core/services/hydration/forecast_hydration_repository.dart';
import 'package:water_mind/src/core/services/hydration/hydration_service_interface.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Service để tính toán và quản lý dự báo lượng nước
class ForecastHydrationService {
  final WeatherRepositoryV2 _weatherRepository;
  final HydrationServiceInterface _hydrationService;
  final ForecastHydrationRepository _forecastRepository;
  final UserDataDao _userDataDao;

  /// Constructor
  ForecastHydrationService(
    this._weatherRepository,
    this._hydrationService,
    this._forecastRepository,
    this._userDataDao,
  );

  /// Tính toán và lưu trữ dự báo lượng nước cho các ngày tiếp theo
  Future<List<ForecastHydrationModel>> calculateAndSaveForecastHydration({
    int days = 3,
    bool forceRefresh = false,
  }) async {
    try {
      // Lấy dữ liệu người dùng
      final userData = await _userDataDao.getUserData();
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Lấy dự báo thời tiết
      final forecastResult = await _weatherRepository.getWeatherForecast(
        days: days,
        forceRefresh: forceRefresh,
      );

      // Xử lý kết quả dự báo
      return forecastResult.when(
        success: (forecast) async {
          // Tính toán lượng nước cho mỗi ngày dự báo
          final forecastHydrationList = <ForecastHydrationModel>[];

          for (final dailyForecast in forecast) {
            // Lấy điều kiện thời tiết từ dự báo
            final weatherCondition = WeatherCondition.fromCode(dailyForecast.conditionCode);

            // Tính toán lượng nước khuyến nghị
            final hydrationModel = _hydrationService.calculateDailyWaterIntake(
              gender: userData.gender,
              weight: userData.weight,
              height: userData.height,
              measureUnit: userData.measureUnit,
              dateOfBirth: userData.dateOfBirth,
              activityLevel: userData.activityLevel,
              livingEnvironment: userData.livingEnvironment,
              weatherCondition: weatherCondition,
              wakeUpTime: userData.wakeUpTime,
              bedTime: userData.bedTime,
            );

            // Tạo model dự báo lượng nước
            final forecastHydration = ForecastHydrationModel(
              date: dailyForecast.date,
              recommendedWaterIntake: hydrationModel.dailyWaterIntake,
              weatherConditionCode: dailyForecast.conditionCode,
              weatherDescription: dailyForecast.conditionText,
              maxTemperature: dailyForecast.maxTemp,
              minTemperature: dailyForecast.minTemp,
              measureUnit: userData.measureUnit,
              lastUpdated: DateTime.now(),
            );

            forecastHydrationList.add(forecastHydration);
          }

          // Lưu dự báo vào cơ sở dữ liệu
          await _forecastRepository.saveForecastHydrationBatch(forecastHydrationList);

          // Xóa dự báo cũ
          await _forecastRepository.cleanupOldForecasts(7); // Giữ dữ liệu 7 ngày

          return forecastHydrationList;
        },
        error: (error) {
          throw Exception('Failed to get weather forecast: $error');
        },
        loading: () {
          throw Exception('Weather forecast is still loading');
        },
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error calculating forecast hydration');
      rethrow;
    }
  }

  /// Lấy dự báo lượng nước đã lưu trữ
  Future<List<ForecastHydrationModel>> getForecastHydration({
    int days = 3,
    bool calculateIfMissing = true,
  }) async {
    try {
      // Lấy dự báo từ cơ sở dữ liệu
      final startDate = DateTime.now();
      final forecasts = await _forecastRepository.getForecastHydrationRange(startDate, days);

      // Nếu không có đủ dự báo và calculateIfMissing = true, tính toán lại
      if (forecasts.length < days && calculateIfMissing) {
        return calculateAndSaveForecastHydration(days: days);
      }

      return forecasts;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration');
      rethrow;
    }
  }
}
