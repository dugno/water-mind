import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Dịch vụ tự động xóa dữ liệu cũ trong cơ sở dữ liệu
class DatabaseCleanupService {
  /// Singleton instance
  static final DatabaseCleanupService _instance = DatabaseCleanupService._internal();

  /// Factory constructor
  factory DatabaseCleanupService() => _instance;

  /// Private constructor
  DatabaseCleanupService._internal();

  /// Timer để lên lịch xóa dữ liệu
  Timer? _cleanupTimer;

  /// Số ngày dữ liệu được giữ lại
  int _daysToKeep = 90; // Mặc định giữ dữ liệu 90 ngày

  /// Getter cho số ngày dữ liệu được giữ lại
  int get daysToKeep => _daysToKeep;

  /// Setter cho số ngày dữ liệu được giữ lại
  set daysToKeep(int days) {
    if (days < 1) {
      AppLogger.warning('Invalid days to keep: $days. Using default value of 90 days.');
      _daysToKeep = 90;
    } else {
      _daysToKeep = days;
      AppLogger.info('Set days to keep to $_daysToKeep days');
    }
  }

  /// Khởi tạo dịch vụ xóa dữ liệu
  void initialize({int? daysToKeep, bool runImmediately = false}) {
    if (daysToKeep != null) {
      this.daysToKeep = daysToKeep;
    }

    // Hủy timer hiện tại nếu có
    _cleanupTimer?.cancel();

    // Lên lịch xóa dữ liệu vào lúc 3 giờ sáng mỗi ngày
    _scheduleNextCleanup(runImmediately);

    AppLogger.info('Database cleanup service initialized. Data will be kept for $_daysToKeep days.');
  }

  /// Lên lịch xóa dữ liệu tiếp theo
  void _scheduleNextCleanup(bool runImmediately) {
    if (runImmediately) {
      _performCleanup();
    }

    // Tính thời gian đến 3 giờ sáng ngày mai
    final now = DateTime.now();
    final nextRun = DateTime(now.year, now.month, now.day, 3, 0, 0).add(const Duration(days: 1));
    final timeUntilNextRun = nextRun.difference(now);

    _cleanupTimer = Timer(timeUntilNextRun, () {
      _performCleanup();
      // Lên lịch cho lần tiếp theo
      _scheduleNextCleanup(false);
    });

    AppLogger.info('Next database cleanup scheduled at $nextRun (in ${timeUntilNextRun.inHours} hours)');
  }

  /// Thực hiện xóa dữ liệu
  Future<void> _performCleanup() async {
    try {
      AppLogger.info('Performing database cleanup...');
      await DatabaseInitializer.cleanupOldData(_daysToKeep);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error during database cleanup');
      debugPrint('Error during database cleanup: $e');
    }
  }

  /// Xóa dữ liệu ngay lập tức
  Future<void> cleanupNow() async {
    await _performCleanup();
  }

  /// Hủy dịch vụ xóa dữ liệu
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    AppLogger.info('Database cleanup service disposed');
  }
}
