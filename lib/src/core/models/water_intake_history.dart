import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'water_intake_entry.dart';

part 'water_intake_history.freezed.dart';
part 'water_intake_history.g.dart';

/// Model representing water intake history for a specific day
@freezed
class WaterIntakeHistory with _$WaterIntakeHistory {
  const factory WaterIntakeHistory({
    required DateTime date,
    required List<WaterIntakeEntry> entries,
    required double dailyGoal, // in milliliters or fluid ounces
    required MeasureUnit measureUnit,
  }) = _WaterIntakeHistory;

  const WaterIntakeHistory._();

  /// Factory constructor for creating a WaterIntakeHistory from JSON
  factory WaterIntakeHistory.fromJson(Map<String, dynamic> json) => _$WaterIntakeHistoryFromJson(json);

  /// Get the total amount of water consumed
  double get totalAmount => entries.fold(0, (sum, entry) => sum + entry.amount);

  /// Get the total effective hydration amount
  double get totalEffectiveAmount => entries.fold(0, (sum, entry) => sum + entry.effectiveAmount);

  /// Get the progress percentage (0.0 to 1.0)
  double get progressPercentage => totalEffectiveAmount / dailyGoal;

  /// Check if the daily goal has been met
  bool get goalMet => totalEffectiveAmount >= dailyGoal;

  /// Get the remaining amount to reach the goal
  double get remainingAmount => dailyGoal - totalEffectiveAmount;

  /// Get the formatted total amount string
  String get formattedTotalAmount {
    if (measureUnit == MeasureUnit.metric) {
      if (totalAmount >= 1000) {
        return '${(totalAmount / 1000).toStringAsFixed(1)} L';
      } else {
        return '${totalAmount.toStringAsFixed(0)} ml';
      }
    } else {
      // Chuyển đổi từ ml sang fl oz (1 ml ≈ 0.033814 fl oz)
      final flOz = totalAmount * 0.033814;
      return '${flOz.toStringAsFixed(1)} fl oz';
    }
  }

  /// Get the formatted daily goal string
  String get formattedDailyGoal {
    if (measureUnit == MeasureUnit.metric) {
      if (dailyGoal >= 1000) {
        return '${(dailyGoal / 1000).toStringAsFixed(1)} L';
      } else {
        return '${dailyGoal.toStringAsFixed(0)} ml';
      }
    } else {
      // Chuyển đổi từ ml sang fl oz (1 ml ≈ 0.033814 fl oz)
      final flOz = dailyGoal * 0.033814;
      return '${flOz.toStringAsFixed(1)} fl oz';
    }
  }
}
