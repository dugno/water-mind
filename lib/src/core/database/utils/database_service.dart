import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Dịch vụ quản lý cơ sở dữ liệu
class DatabaseService {
  /// Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();

  /// Factory constructor
  factory DatabaseService() => _instance;

  /// Private constructor
  DatabaseService._internal();

  /// Khởi tạo dịch vụ cơ sở dữ liệu
  Future<void> initialize({
    int? daysToKeep,
    bool enableCleanup = true,
    bool runCleanupImmediately = false,
  }) async {
    try {
      // Khởi tạo cơ sở dữ liệu
      await DatabaseInitializer.initialize();

      // Lưu ý: Tất cả logic xóa dữ liệu đã bị loại bỏ
      // Tất cả dữ liệu sẽ được giữ lại trong suốt vòng đời ứng dụng
      AppLogger.info('Database service initialized successfully. All data will be kept for the entire app lifecycle.');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error initializing database service');
      debugPrint('Error initializing database service: $e');
      rethrow;
    }
  }

  /// Đóng dịch vụ cơ sở dữ liệu
  Future<void> close() async {
    try {
      // Đóng cơ sở dữ liệu
      await DatabaseInitializer.close();

      AppLogger.info('Database service closed successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error closing database service');
      debugPrint('Error closing database service: $e');
    }
  }

  /// Phương thức này được giữ lại để tương thích với mã hiện có
  /// nhưng không còn thực hiện xóa dữ liệu
  Future<void> cleanupOldData() async {
    // Không làm gì cả, giữ lại tất cả dữ liệu
    AppLogger.info('Database cleanup disabled. All data will be kept for the entire app lifecycle.');
  }
}
