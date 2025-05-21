import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/water_intake_dao.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_change_notifier.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Provider để lấy tổng lượng nước đã uống từ khi sử dụng app
final totalWaterIntakeProvider = FutureProvider<double>((ref) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);

  final dao = ref.watch(waterIntakeDaoProvider);
  return _calculateTotalWaterIntake(dao);
});

/// Provider để lấy tổng lượng nước đã uống từ khi sử dụng app với đơn vị đo
final formattedTotalWaterIntakeProvider = FutureProvider<({double amount, MeasureUnit unit})>((ref) async {
  // Lắng nghe sự thay đổi từ waterIntakeChangeNotifierProvider để cập nhật khi có thay đổi
  ref.watch(waterIntakeChangeNotifierProvider);

  final dao = ref.watch(waterIntakeDaoProvider);
  final totalAmount = await _calculateTotalWaterIntake(dao);

  // Lấy đơn vị đo từ lịch sử gần nhất
  final histories = await dao.getAllWaterIntakeHistory(limit: 1);
  final unit = histories.isNotEmpty ? histories.first.measureUnit : MeasureUnit.metric;

  return (amount: totalAmount, unit: unit);
});

/// Tính tổng lượng nước đã uống từ khi sử dụng app
Future<double> _calculateTotalWaterIntake(WaterIntakeDao dao) async {
  try {
    AppLogger.info('Calculating total water intake');

    // Lấy tất cả lịch sử uống nước
    final histories = await dao.getAllWaterIntakeHistory();
    AppLogger.info('Found ${histories.length} days with water intake data');

    // Tính tổng lượng nước
    double totalAmount = 0;
    for (final history in histories) {
      // Đảm bảo tất cả đều được chuyển về đơn vị ml
      if (history.measureUnit == MeasureUnit.metric) {
        totalAmount += history.totalAmount; // Đã là ml
      } else {
        // Chuyển đổi từ fluid ounces sang ml
        totalAmount += history.totalAmount * 29.5735;
      }
    }

    AppLogger.info('Total water intake: $totalAmount ml');
    return totalAmount;
  } catch (e) {
    AppLogger.reportError(e, StackTrace.current, 'Error calculating total water intake');
    rethrow;
  }
}

/// Định dạng tổng lượng nước đã uống thành chuỗi dễ đọc
String formatTotalWaterIntake(double amount, MeasureUnit unit) {
  if (unit == MeasureUnit.metric) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)} m³';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} L';
    } else {
      return '${amount.toStringAsFixed(0)} ml';
    }
  } else {
    // Chuyển đổi từ ml sang fluid ounces
    final fluidOunces = amount / 29.5735;
    if (fluidOunces >= 128) {
      // Hiển thị theo gallon
      return '${(fluidOunces / 128).toStringAsFixed(2)} gal';
    } else {
      return '${fluidOunces.toStringAsFixed(1)} fl oz';
    }
  }
}
