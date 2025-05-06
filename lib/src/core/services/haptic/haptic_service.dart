import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:water_mind/src/common/constant/platform.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Các loại phản hồi xúc giác
enum HapticFeedbackType {
  /// Phản hồi nhẹ - thường dùng cho tap buttons
  light,

  /// Phản hồi trung bình - thường dùng cho selections
  medium,

  /// Phản hồi nặng - thường dùng cho các tương tác quan trọng
  heavy,

  /// Phản hồi thành công
  success,

  /// Phản hồi cảnh báo
  warning,

  /// Phản hồi lỗi
  error,

  /// Phản hồi cho việc chọn
  selection,
}

/// Service quản lý phản hồi xúc giác trong app
class HapticService {
  /// Instance singleton
  static final HapticService instance = HapticService._();

  HapticService._() {
    _initializeHapticSupport();
  }

  /// Flag để enable/disable haptic feedback
  bool enabled = true;

  /// Flag để check thiết bị có hỗ trợ haptic không
  bool _isSupported = false;

  /// Getter cho trạng thái hỗ trợ haptic
  bool get isSupported => _isSupported;

  /// Khởi tạo và kiểm tra thiết bị có hỗ trợ haptic không
  Future<void> _initializeHapticSupport() async {
    try {
      // Web không hỗ trợ haptic
      if (kIsWeb) {
        _isSupported = false;
        return;
      }

      // Chỉ hỗ trợ trên mobile và tablet
      if (!kIsAndroid && !kIsIOS) {
        _isSupported = false;
        return;
      }

      // Thử phát một haptic nhẹ để kiểm tra
      await HapticFeedback.lightImpact();
      _isSupported = true;
    } catch (e) {
      _isSupported = false;
    }
  }

  /// Phát haptic feedback theo type
  void feedback(HapticFeedbackType type) {
    // Kiểm tra điều kiện để phát haptic
    if (!enabled || !_isSupported) return;

    try {
      switch (type) {
        case HapticFeedbackType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.success:
          _playPattern([
            const Duration(milliseconds: 50),
            const Duration(milliseconds: 100),
          ]);
          break;
        case HapticFeedbackType.warning:
          _playPattern([
            const Duration(milliseconds: 100),
            const Duration(milliseconds: 100),
            const Duration(milliseconds: 100),
          ]);
          break;
        case HapticFeedbackType.error:
          _playPattern([
            const Duration(milliseconds: 150),
            const Duration(milliseconds: 100),
            const Duration(milliseconds: 150),
          ]);
          break;
        case HapticFeedbackType.selection:
          HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      // Ignore haptic errors
      AppLogger.log.e('Haptic feedback failed: $e');
    }
  }

  /// Phát một chuỗi vibration theo pattern
  Future<void> _playPattern(List<Duration> pattern) async {
    if (!_isSupported) return;

    try {
      for (final duration in pattern) {
        await HapticFeedback.vibrate();
        await Future.delayed(duration);
      }
    } catch (e) {
      AppLogger.log.e('Haptic pattern failed: $e');
    }
  }
}
