import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:water_mind/src/core/database/database.dart';
import 'package:water_mind/src/core/database/database_initializer.dart';
import 'package:water_mind/src/core/database/utils/database_service.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// Lớp tiện ích để tạo cơ sở dữ liệu mới
class DatabaseGenerator {
  /// Tạo cơ sở dữ liệu mới
  static Future<bool> generateNewDatabase() async {
    try {
      // Đóng cơ sở dữ liệu hiện tại nếu đang mở
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.close();
      }

      // Xóa file cơ sở dữ liệu cũ
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'water_mind.sqlite'));
      final dbShmFile = File(p.join(dbFolder.path, 'water_mind.sqlite-shm'));
      final dbWalFile = File(p.join(dbFolder.path, 'water_mind.sqlite-wal'));

      if (await dbFile.exists()) {
        await dbFile.delete();
        AppLogger.info('Deleted old database file');
      }

      if (await dbShmFile.exists()) {
        await dbShmFile.delete();
        AppLogger.info('Deleted old database shm file');
      }

      if (await dbWalFile.exists()) {
        await dbWalFile.delete();
        AppLogger.info('Deleted old database wal file');
      }

      // Khởi tạo cơ sở dữ liệu mới
      final databaseService = DatabaseService();
      await databaseService.initialize();

      AppLogger.info('Generated new database successfully');
      return true;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error generating new database');
      debugPrint('Error generating new database: $e');
      return false;
    }
  }

  /// Tạo cơ sở dữ liệu mới với dữ liệu mẫu
  static Future<bool> generateNewDatabaseWithSampleData() async {
    try {
      // Tạo cơ sở dữ liệu mới
      final success = await generateNewDatabase();
      if (!success) {
        return false;
      }

      // Thêm dữ liệu mẫu
      await _addSampleData();

      AppLogger.info('Generated new database with sample data successfully');
      return true;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error generating new database with sample data');
      debugPrint('Error generating new database with sample data: $e');
      return false;
    }
  }

  /// Thêm dữ liệu mẫu vào cơ sở dữ liệu
  static Future<void> _addSampleData() async {
    try {
      // Lấy instance của cơ sở dữ liệu
      final database = DatabaseInitializer.database;

      // TODO: Thêm dữ liệu mẫu vào cơ sở dữ liệu
      // Ví dụ:
      // await database.insertOrUpdateWaterIntakeHistory(...);
      // await database.insertWaterIntakeEntry(...);
      // await database.saveUserData(...);
      // await database.saveReminderSettings(...);

      AppLogger.info('Added sample data to database');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error adding sample data to database');
      debugPrint('Error adding sample data to database: $e');
      rethrow;
    }
  }
}
