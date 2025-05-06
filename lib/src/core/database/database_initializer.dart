import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Lớp khởi tạo cơ sở dữ liệu
/// Implements singleton pattern to ensure only one database instance exists
class DatabaseInitializer {
  // Private static instance variable
  static AppDatabase? _instance;

  // Flag to track if initialization has been completed
  static bool _initialized = false;

  /// Getter cho database instance
  /// This will throw an error if accessed before initialization
  static AppDatabase get database {
    if (!_initialized) {
      throw StateError('Database has not been initialized. Call DatabaseInitializer.initialize() first.');
    }
    return _instance!;
  }

  /// Check if database is initialized
  static bool get isInitialized => _initialized;

  /// Khởi tạo cơ sở dữ liệu
  /// This should be called only once at app startup
  static Future<void> initialize() async {
    if (_initialized) {
      AppLogger.warning('Database already initialized. Skipping initialization.');
      return;
    }

    try {
      // Set drift runtime options to avoid multiple database warnings
      // Only do this if you're sure your app is properly handling database access
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

      // Khởi tạo cơ sở dữ liệu as a singleton
      _instance = AppDatabase();
      _initialized = true;

      AppLogger.info('Database initialized successfully');
    } catch (e) {
      _initialized = false;
      _instance = null;
      AppLogger.reportError(e, StackTrace.current, 'Error initializing database');
      debugPrint('Error initializing database: $e');
    }
  }

  /// Đóng cơ sở dữ liệu
  /// This should be called when the app is shutting down
  static Future<void> close() async {
    if (!_initialized || _instance == null) {
      AppLogger.warning('Database not initialized or already closed. Skipping close operation.');
      return;
    }

    try {
      await _instance!.close();
      _instance = null;
      _initialized = false;
      AppLogger.info('Database closed successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error closing database');
      debugPrint('Error closing database: $e');
    }
  }
}
