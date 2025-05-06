import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

part 'logger_provider.g.dart';

/// Provider for AppLogger initialization
@riverpod
bool appLoggerInitialized(Ref ref) {
  // This provider is used to track if the logger has been initialized
  // It's initialized in main.dart, so we just return true here
  return true;
}

/// Provider for AppLogger
@riverpod
class AppLoggerNotifier extends _$AppLoggerNotifier {
  @override
  void build() {
    // Ensure the logger is initialized
    ref.watch(appLoggerInitializedProvider);
    
    // No state is needed, as AppLogger is a static class
    return;
  }
  
  /// Log a debug message
  void debug(String message, [dynamic data]) {
    AppLogger.debug(message, data);
  }
  
  /// Log an info message
  void info(String message, [dynamic data]) {
    AppLogger.info(message, data);
  }
  
  /// Log a warning message
  void warning(String message, [dynamic data]) {
    AppLogger.warning(message, data);
  }
  
  /// Report an error
  Future<void> reportError(dynamic error, [StackTrace? stackTrace, String message = '']) async {
    await AppLogger.reportError(error, stackTrace, message);
  }
}
