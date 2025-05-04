import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

part 'hydration_model.freezed.dart';

/// Model representing hydration data and recommendations
@freezed
class HydrationModel with _$HydrationModel {
  const factory HydrationModel({
    /// Daily water intake recommendation in milliliters (for metric) or fluid ounces (for imperial)
    required double dailyWaterIntake,
    
    /// The measurement unit used for the water intake value
    required MeasureUnit measureUnit,
    
    /// Factors that influenced the calculation
    required Map<String, double> calculationFactors,
  }) = _HydrationModel;

  const HydrationModel._();
  
  /// Get the daily water intake in liters (if metric) or fluid ounces (if imperial)
  double get waterIntakeInPreferredUnit {
    if (measureUnit == MeasureUnit.metric) {
      return dailyWaterIntake / 1000; // Convert ml to liters
    } else {
      return dailyWaterIntake; // Already in fluid ounces
    }
  }
  
  /// Get the daily water intake in milliliters (metric)
  double get waterIntakeInMilliliters {
    if (measureUnit == MeasureUnit.metric) {
      return dailyWaterIntake;
    } else {
      return dailyWaterIntake * 29.5735; // Convert fluid ounces to milliliters
    }
  }
  
  /// Get the daily water intake in fluid ounces (imperial)
  double get waterIntakeInFluidOunces {
    if (measureUnit == MeasureUnit.imperial) {
      return dailyWaterIntake;
    } else {
      return dailyWaterIntake / 29.5735; // Convert milliliters to fluid ounces
    }
  }
  
  /// Get the formatted string representation of the daily water intake
  String getFormattedWaterIntake() {
    if (measureUnit == MeasureUnit.metric) {
      if (dailyWaterIntake >= 1000) {
        return '${(dailyWaterIntake / 1000).toStringAsFixed(1)} L';
      } else {
        return '${dailyWaterIntake.toStringAsFixed(0)} ml';
      }
    } else {
      return '${dailyWaterIntake.toStringAsFixed(1)} fl oz';
    }
  }
}
