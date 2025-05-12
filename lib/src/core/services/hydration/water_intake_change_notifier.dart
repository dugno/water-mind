import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier để thông báo khi dữ liệu uống nước thay đổi
class WaterIntakeChangeNotifier extends StateNotifier<DateTime> {
  /// Constructor
  WaterIntakeChangeNotifier() : super(DateTime.now());
  
  /// Phương thức này được gọi khi có thay đổi dữ liệu
  void notifyDataChanged() {
    // Cập nhật state với thời gian hiện tại để kích hoạt các listener
    state = DateTime.now();
  }
}

/// Provider để truy cập notifier
final waterIntakeChangeNotifierProvider = StateNotifierProvider<WaterIntakeChangeNotifier, DateTime>((ref) {
  return WaterIntakeChangeNotifier();
});
