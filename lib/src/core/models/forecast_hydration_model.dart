import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

part 'forecast_hydration_model.freezed.dart';
part 'forecast_hydration_model.g.dart';

/// Model cho dự báo lượng nước
@freezed
class ForecastHydrationModel with _$ForecastHydrationModel {
  /// Constructor
  const factory ForecastHydrationModel({
    /// Ngày dự báo
    required DateTime date,
    
    /// Lượng nước khuyến nghị (ml hoặc fl oz)
    required double recommendedWaterIntake,
    
    /// Mã điều kiện thời tiết dự báo
    required int weatherConditionCode,
    
    /// Mô tả điều kiện thời tiết
    required String weatherDescription,
    
    /// Nhiệt độ tối đa dự báo (°C)
    required double maxTemperature,
    
    /// Nhiệt độ tối thiểu dự báo (°C)
    required double minTemperature,
    
    /// Đơn vị đo lường (0: metric, 1: imperial)
    required MeasureUnit measureUnit,
    
    /// Thời gian cập nhật cuối cùng
    DateTime? lastUpdated,
  }) = _ForecastHydrationModel;

  /// Factory constructor for creating a ForecastHydrationModel from JSON
  factory ForecastHydrationModel.fromJson(Map<String, dynamic> json) => 
      _$ForecastHydrationModelFromJson(json);
      
  /// Private constructor for the freezed class
  const ForecastHydrationModel._();
  
  /// Get the weather condition from the code
  WeatherCondition get weatherCondition => WeatherCondition.fromCode(weatherConditionCode);
  
  /// Get the formatted recommended water intake
  String getFormattedWaterIntake() {
    if (measureUnit == MeasureUnit.metric) {
      if (recommendedWaterIntake >= 1000) {
        return '${(recommendedWaterIntake / 1000).toStringAsFixed(1)} L';
      } else {
        return '${recommendedWaterIntake.toStringAsFixed(0)} ml';
      }
    } else {
      return '${recommendedWaterIntake.toStringAsFixed(1)} fl oz';
    }
  }
}
