import 'dart:async';
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

  // Completer to track initialization process
  static final Completer<void> _initCompleter = Completer<void>();

  // Flag to track if initialization is in progress
  static bool _isInitializing = false;

  // Counter for open connections
  static int _openConnections = 0;

  // Constants for retry mechanism
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

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
      AppLogger.info('Database already initialized. Returning existing instance.');
      return;
    }

    if (_isInitializing) {
      AppLogger.info('Database initialization in progress. Waiting for completion.');
      return _initCompleter.future;
    }

    _isInitializing = true;
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        // Set drift runtime options to avoid multiple database warnings
        driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

        // Khởi tạo cơ sở dữ liệu as a singleton
        _instance = AppDatabase();

        // Kiểm tra kết nối
        await _instance!.validateDatabaseIntegrity();

        _initialized = true;
        _isInitializing = false;
        _openConnections = 1;

        if (!_initCompleter.isCompleted) {
          _initCompleter.complete();
        }

        AppLogger.info('Database initialized successfully');
        return;
      } catch (e) {
        retryCount++;

        if (retryCount >= _maxRetries) {
          _initialized = false;
          _isInitializing = false;
          _instance = null;

          final error = 'Error initializing database after $_maxRetries attempts: $e';
          AppLogger.reportError(e, StackTrace.current, error);
          debugPrint(error);

          if (!_initCompleter.isCompleted) {
            _initCompleter.completeError(e);
          }

          rethrow;
        } else {
          AppLogger.warning('Database initialization failed, retrying (${retryCount}/$_maxRetries): $e');
          await Future.delayed(_retryDelay * retryCount);
        }
      }
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
      _openConnections = 0;
      AppLogger.info('Database closed successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error closing database');
      debugPrint('Error closing database: $e');
    }
  }

  /// Đăng ký một kết nối mới
  static void registerConnection() {
    _openConnections++;
    AppLogger.info('Database connection registered. Total connections: $_openConnections');
  }

  /// Hủy đăng ký một kết nối
  static void unregisterConnection() {
    if (_openConnections > 0) {
      _openConnections--;
      AppLogger.info('Database connection unregistered. Total connections: $_openConnections');
    }
  }

  /// Phương thức này đã bị loại bỏ để giữ lại tất cả dữ liệu
  /// Được giữ lại để tương thích với mã hiện có nhưng không thực hiện gì cả
  static Future<void> cleanupOldData(int daysToKeep) async {
    // Không làm gì cả, giữ lại tất cả dữ liệu
    AppLogger.info('Database cleanup disabled. All data will be kept for the entire app lifecycle.');
  }
}
