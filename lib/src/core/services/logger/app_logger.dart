import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart' as logger;
import 'package:logging/logging.dart' as logging;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water_mind/src/common/constant/platform.dart';

final Map _loggingToLoggerLevel = {
  logging.Level.ALL: logger.Level.all,
  logging.Level.FINEST: logger.Level.trace,
  logging.Level.FINER: logger.Level.debug,
  logging.Level.FINE: logger.Level.info,
  logging.Level.CONFIG: logger.Level.info,
  logging.Level.INFO: logger.Level.info,
  logging.Level.WARNING: logger.Level.warning,
  logging.Level.SEVERE: logger.Level.error,
  logging.Level.SHOUT: logger.Level.fatal,
  logging.Level.OFF: logger.Level.off,
};

class AppLogger {
  static late final logger.Logger log;
  static late final File logFile;

  static initialize(bool verbose) {
    log = logger.Logger(
      level: kDebugMode || (verbose && kReleaseMode)
          ? logger.Level.debug
          : logger.Level.info,
    );
  }

  static void _initInternalPackageLoggers() {
    if (!kDebugMode) return;
    logging.hierarchicalLoggingEnabled = true;
    logging.Logger('KoroAI.Client')
      ..level = logging.Level.SEVERE
      ..onRecord.listen((logging.LogRecord rec) {
        log.log(
          _loggingToLoggerLevel[rec.level] ?? logger.Level.info,
          rec.message,
          error: rec.error,
          stackTrace: rec.stackTrace,
        );
      });
  }

  static R? runZoned<R>(R Function() body) {
    return runZonedGuarded<R>(() {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        reportError(details.exception, details.stack ?? StackTrace.current);
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        reportError(error, stackTrace);
        return true;
      };

      if (!kIsWeb) {
        Isolate.current.addErrorListener(
          RawReceivePort((pair) async {
            final isolateError = pair[0] as Object;
            final isolateStack = pair[1] as StackTrace;
            await reportError(isolateError, isolateStack);
          }).sendPort,
        );
      }
      _initInternalPackageLoggers();
      getLogsPath().then((logFile) => AppLogger.logFile = logFile);
      return body();

    },
    (error,stackTrace){
      log.e(error, stackTrace: stackTrace);
    },
    );
  }

  static Future<File> getLogsPath() async {
    try {
      // Define the log file name
      const String logFileName = 'water_mind_logs.txt';

      // Get the appropriate directory based on platform
      String logsDir;

      if (kIsAndroid) {
        // On Android, use external storage if available
        final externalDir = await getExternalStorageDirectory();
        logsDir = externalDir?.path ?? (await getApplicationDocumentsDirectory()).path;
      } else if (kIsMacOS) {
        // On macOS, use Library/Logs directory
        final libraryDir = await getLibraryDirectory();
        logsDir = join(libraryDir.path, 'Logs', 'water_mind');
      } else if (kIsIOS) {
        // On iOS, use Documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        logsDir = join(docsDir.path, 'Logs');
      } else if (kIsWindows) {
        // On Windows, use AppData/Local directory
        final docsDir = await getApplicationDocumentsDirectory();
        logsDir = join(docsDir.path, 'Logs');
      } else if (kIsLinux) {
        // On Linux, use home directory
        final docsDir = await getApplicationDocumentsDirectory();
        logsDir = join(docsDir.path, '.water_mind', 'logs');
      } else {
        // Default fallback
        final docsDir = await getApplicationDocumentsDirectory();
        logsDir = join(docsDir.path, 'Logs');
      }

      // Ensure the logs directory exists
      final logsDirectory = Directory(logsDir);
      if (!await logsDirectory.exists()) {
        await logsDirectory.create(recursive: true);
      }

      // Create the log file path
      final logFilePath = join(logsDir, logFileName);
      final logFile = File(logFilePath);

      // Create the file if it doesn't exist
      if (!await logFile.exists()) {
        await logFile.create(recursive: true);
      }

      debugPrint('Log file path: $logFilePath');
      return logFile;
    } catch (e, stackTrace) {
      // Handle any errors and provide a fallback
      debugPrint('Error creating log file: $e');
      debugPrint('Stack trace: $stackTrace');

      // Fallback to a simple file in the application documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      final fallbackPath = join(docsDir.path, 'water_mind_logs.txt');
      final fallbackFile = File(fallbackPath);

      if (!await fallbackFile.exists()) {
        await fallbackFile.create(recursive: true);
      }

      debugPrint('Using fallback log file path: $fallbackPath');
      return fallbackFile;
    }
  }

  /// Logs a debug message
  ///
  /// Use this method for detailed information that is useful for debugging
  /// but might be too verbose for normal operation.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.debug('Processing item 5 of 42');
  /// AppLogger.debug('API response details', response.body);
  /// ```
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      log.d(data != null ? '$message - $data' : message);
    }
    // Debug logs are not written to file in release mode
  }

  /// Logs an informational message
  ///
  /// Use this method for general information that is useful for understanding
  /// the flow of the application during normal operation.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.info('User logged in successfully');
  /// AppLogger.info('Loading data from API', {'userId': 123});
  /// ```
  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      log.i(data != null ? '$message - $data' : message);
    }
    if (kReleaseMode) {
      try {
        logFile.writeAsStringSync(
          "[${DateTime.now()}][INFO] $message ${data != null ? '- $data' : ''}\n",
          mode: FileMode.writeOnlyAppend,
        );
      } catch (e) {
        // Silently handle file writing errors in release mode
        debugPrint('Failed to write info log to file: $e');
      }
    }
  }

  /// Logs a warning message
  ///
  /// Use this method for potentially harmful situations that don't cause the application
  /// to fail but should be addressed.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.warning('API rate limit approaching 80%');
  /// AppLogger.warning('Deprecated method called', {'method': 'oldMethod', 'caller': 'HomeScreen'});
  /// ```
  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      log.w(data != null ? '$message - $data' : message);
    }
    if (kReleaseMode) {
      try {
        logFile.writeAsStringSync(
          "[${DateTime.now()}][WARNING] $message ${data != null ? '- $data' : ''}\n",
          mode: FileMode.writeOnlyAppend,
        );
      } catch (e) {
        // Silently handle file writing errors in release mode
        debugPrint('Failed to write warning log to file: $e');
      }
    }
  }
  /// Reports an error with optional stack trace and message
  static Future<void> reportError(
    dynamic error, [
    StackTrace? stackTrace,
    message = '',
  ]) async {
    if (kDebugMode) {
      log.e(error, stackTrace: stackTrace);
    }
    if (kReleaseMode) {
      await logFile.writeAsString(
        "[${DateTime.now()}][ERROR]---------------------\n"
        "$error\n$stackTrace\n"
        "----------------------------------------\n",
        mode: FileMode.writeOnlyAppend,
      );
    }
  }
}

class AppLoggerProviderObserver extends ProviderObserver {
  const AppLoggerProviderObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.reportError(error, stackTrace);
  }
}
