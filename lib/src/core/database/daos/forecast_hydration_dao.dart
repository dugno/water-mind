import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/models/forecast_hydration_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// DAO cho dự báo lượng nước
class ForecastHydrationDao {
  final AppDatabase _db;

  /// Constructor
  ForecastHydrationDao(this._db);

  /// Lấy dự báo lượng nước cho một ngày cụ thể
  Future<ForecastHydrationModel?> getForecastHydration(DateTime date) async {
    try {
      final data = await _db.getForecastHydration(date);
      if (data == null) {
        return null;
      }
      return dataToModel(data);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration');
      rethrow;
    }
  }

  /// Lấy dự báo lượng nước cho nhiều ngày
  Future<List<ForecastHydrationModel>> getForecastHydrationRange(
    DateTime startDate,
    int days,
  ) async {
    try {
      final dataList = await _db.getForecastHydrationRange(startDate, days);
      return dataList.map((data) => dataToModel(data)).toList();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration range');
      rethrow;
    }
  }

  /// Lưu dự báo lượng nước
  Future<void> saveForecastHydration(ForecastHydrationModel forecast) async {
    try {
      await _db.saveForecastHydration(modelToCompanion(forecast));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving forecast hydration');
      rethrow;
    }
  }

  /// Lưu nhiều dự báo lượng nước
  Future<void> saveForecastHydrationBatch(List<ForecastHydrationModel> forecasts) async {
    try {
      for (final forecast in forecasts) {
        await saveForecastHydration(forecast);
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving forecast hydration batch');
      rethrow;
    }
  }

  /// Phương thức này được giữ lại để tương thích với mã hiện có
  /// nhưng không còn thực hiện xóa dữ liệu
  Future<int> cleanupOldForecasts(int daysToKeep) async {
    // Không làm gì cả, giữ lại tất cả dữ liệu
    AppLogger.info('Database cleanup disabled. All forecast data will be kept for the entire app lifecycle.');
    return 0; // Trả về 0 để chỉ ra rằng không có bản ghi nào bị xóa
  }

  /// Chuyển đổi từ dữ liệu bảng sang model
  ForecastHydrationModel dataToModel(dynamic data) {
    try {
      return ForecastHydrationModel(
        date: data.date,
        recommendedWaterIntake: data.recommendedWaterIntake,
        weatherConditionCode: data.weatherConditionCode,
        weatherDescription: data.weatherDescription,
        maxTemperature: data.maxTemperature,
        minTemperature: data.minTemperature,
        measureUnit: data.measureUnit,
        lastUpdated: data.lastUpdated,
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting data to forecast hydration model');
      rethrow;
    }
  }

  /// Chuyển đổi từ model sang dữ liệu bảng
  dynamic modelToCompanion(ForecastHydrationModel model) {
    try {
      final dateString = model.date.toIso8601String().split('T')[0];
      return ForecastHydrationTableCompanion(
        id: Value(dateString),
        date: Value(model.date),
        recommendedWaterIntake: Value(model.recommendedWaterIntake),
        weatherConditionCode: Value(model.weatherConditionCode),
        weatherDescription: Value(model.weatherDescription),
        maxTemperature: Value(model.maxTemperature),
        minTemperature: Value(model.minTemperature),
        measureUnit: Value(model.measureUnit),
        lastUpdated: Value(model.lastUpdated ?? DateTime.now()),
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error converting forecast hydration model to companion');
      rethrow;
    }
  }
}
