import 'package:water_mind/src/core/database/daos/forecast_hydration_dao.dart';
import 'package:water_mind/src/core/models/forecast_hydration_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Interface cho repository dự báo lượng nước
abstract class ForecastHydrationRepository {
  /// Lấy dự báo lượng nước cho một ngày cụ thể
  Future<ForecastHydrationModel?> getForecastHydration(DateTime date);

  /// Lấy dự báo lượng nước cho nhiều ngày
  Future<List<ForecastHydrationModel>> getForecastHydrationRange(
    DateTime startDate,
    int days,
  );

  /// Lưu dự báo lượng nước
  Future<void> saveForecastHydration(ForecastHydrationModel forecast);

  /// Lưu nhiều dự báo lượng nước
  Future<void> saveForecastHydrationBatch(List<ForecastHydrationModel> forecasts);

  /// Xóa dự báo lượng nước cũ
  Future<int> cleanupOldForecasts(int daysToKeep);
}

/// Triển khai repository sử dụng Drift
class ForecastHydrationRepositoryImpl implements ForecastHydrationRepository {
  final ForecastHydrationDao _dao;

  /// Constructor
  ForecastHydrationRepositoryImpl(this._dao);

  @override
  Future<ForecastHydrationModel?> getForecastHydration(DateTime date) async {
    try {
      return await _dao.getForecastHydration(date);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration');
      rethrow;
    }
  }

  @override
  Future<List<ForecastHydrationModel>> getForecastHydrationRange(
    DateTime startDate,
    int days,
  ) async {
    try {
      return await _dao.getForecastHydrationRange(startDate, days);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration range');
      rethrow;
    }
  }

  @override
  Future<void> saveForecastHydration(ForecastHydrationModel forecast) async {
    try {
      await _dao.saveForecastHydration(forecast);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving forecast hydration');
      rethrow;
    }
  }

  @override
  Future<void> saveForecastHydrationBatch(List<ForecastHydrationModel> forecasts) async {
    try {
      await _dao.saveForecastHydrationBatch(forecasts);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving forecast hydration batch');
      rethrow;
    }
  }

  @override
  Future<int> cleanupOldForecasts(int daysToKeep) async {
    try {
      return await _dao.cleanupOldForecasts(daysToKeep);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error cleaning up old forecasts');
      rethrow;
    }
  }
}
