import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

part 'daily_water_summary.freezed.dart';
part 'daily_water_summary.g.dart';

/// Model đại diện cho tổng lượng nước uống theo ngày
@freezed
class DailyWaterSummary with _$DailyWaterSummary {
  const factory DailyWaterSummary({
    required DateTime date,
    required String userId,
    required double totalAmount, // tổng lượng nước đã uống (ml hoặc fl oz)
    required double totalEffectiveAmount, // tổng lượng nước hiệu quả (ml hoặc fl oz)
    required double dailyGoal, // mục tiêu uống nước hàng ngày (ml hoặc fl oz)
    required MeasureUnit measureUnit,
    @Default(false) bool goalMet,
    DateTime? lastUpdated,
  }) = _DailyWaterSummary;

  const DailyWaterSummary._();

  /// Factory constructor for creating a DailyWaterSummary from JSON
  factory DailyWaterSummary.fromJson(Map<String, dynamic> json) => _$DailyWaterSummaryFromJson(json);

  /// Get the progress percentage (0.0 to 1.0)
  double get progressPercentage => totalEffectiveAmount / dailyGoal;

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
      return '${totalAmount.toStringAsFixed(1)} fl oz';
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
      return '${dailyGoal.toStringAsFixed(1)} fl oz';
    }
  }
}
