import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/database/utils/database_cleanup_service.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Dịch vụ quản lý cơ sở dữ liệu
class DatabaseService {
  /// Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();

  /// Factory constructor
  factory DatabaseService() => _instance;

  /// Private constructor
  DatabaseService._internal();

  /// Dịch vụ xóa dữ liệu cũ
  final DatabaseCleanupService _cleanupService = DatabaseCleanupService();

  /// Số ngày dữ liệu được giữ lại
  int _daysToKeep = 90; // Mặc định giữ dữ liệu 90 ngày

  /// Getter cho số ngày dữ liệu được giữ lại
  int get daysToKeep => _daysToKeep;

  /// Setter cho số ngày dữ liệu được giữ lại
  set daysToKeep(int days) {
    _daysToKeep = days;
    _cleanupService.daysToKeep = days;
  }

  /// Khởi tạo dịch vụ cơ sở dữ liệu
  Future<void> initialize({
    int? daysToKeep,
    bool enableCleanup = true,
    bool runCleanupImmediately = false,
  }) async {
    try {
      // Khởi tạo cơ sở dữ liệu
      await DatabaseInitializer.initialize();

      // Khởi tạo dịch vụ xóa dữ liệu cũ
      if (enableCleanup) {
        if (daysToKeep != null) {
          this.daysToKeep = daysToKeep;
        }
        _cleanupService.initialize(
          daysToKeep: this.daysToKeep,
          runImmediately: runCleanupImmediately,
        );
      }

      AppLogger.info('Database service initialized successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error initializing database service');
      debugPrint('Error initializing database service: $e');
      rethrow;
    }
  }

  /// Đóng dịch vụ cơ sở dữ liệu
  Future<void> close() async {
    try {
      // Đóng dịch vụ xóa dữ liệu cũ
      _cleanupService.dispose();

      // Đóng cơ sở dữ liệu
      await DatabaseInitializer.close();

      AppLogger.info('Database service closed successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error closing database service');
      debugPrint('Error closing database service: $e');
    }
  }

  /// Xóa dữ liệu cũ ngay lập tức
  Future<void> cleanupOldData() async {
    await _cleanupService.cleanupNow();
  }
}
