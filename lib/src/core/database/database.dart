import 'dart:io';
import 'package:drift/drift.dart' hide Table;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Column;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:water_mind/src/core/database/tables.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/reminders/models/standard_reminder_time.dart' as reminder_models;
import 'package:water_mind/src/core/utils/utils.dart';
import 'package:water_mind/src/core/database/converters/type_converters.dart';

// Alias for drift.Table to avoid conflicts with Flutter's Table
import 'package:drift/drift.dart' as drift;

part 'database.g.dart';

/// Các phiên bản của cơ sở dữ liệu
class DatabaseVersions {
  /// Phiên bản ban đầu với bảng WaterIntakeHistoryTable và WaterIntakeEntryTable
  static const int initialVersion = 1;

  /// Phiên bản thêm bảng UserDataTable và ReminderSettingsTable
  static const int addUserAndReminderTables = 2;

  /// Phiên bản cải tiến với TypeConverter và Index
  static const int enhancedVersion = 3;

  /// Phiên bản hiện tại
  static const int currentVersion = enhancedVersion;
}

/// Cơ sở dữ liệu chính của ứng dụng
@DriftDatabase(tables: [
  WaterIntakeHistoryTable,
  WaterIntakeEntryTable,
  UserDataTable,
  ReminderSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  /// Constructor
  AppDatabase() : super(_openConnection());

  /// Phiên bản cơ sở dữ liệu
  @override
  int get schemaVersion => DatabaseVersions.currentVersion;

  /// Xử lý nâng cấp cơ sở dữ liệu
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        AppLogger.info('Creating database at version $schemaVersion');
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        AppLogger.info('Upgrading database from version $from to $to');

        // Nâng cấp từ phiên bản 1 lên 2
        if (from < DatabaseVersions.addUserAndReminderTables && to >= DatabaseVersions.addUserAndReminderTables) {
          AppLogger.info('Adding user and reminder tables');
          await m.createTable(userDataTable);
          await m.createTable(reminderSettingsTable);
        }

        // Nâng cấp từ phiên bản 2 lên 3
        if (from < DatabaseVersions.enhancedVersion && to >= DatabaseVersions.enhancedVersion) {
          AppLogger.info('Enhancing database with indexes');

          // Thêm index cho các bảng
          await _addIndexes(m);

          // Thêm ràng buộc cho các trường dữ liệu
          await _addConstraints(m);
        }
      },
      beforeOpen: (details) async {
        // Kiểm tra tính toàn vẹn của cơ sở dữ liệu
        await validateDatabaseIntegrity();

        // Xóa dữ liệu cũ nếu cần
        if (details.wasCreated) {
          AppLogger.info('Database was created');
        }

        return;
      },
    );
  }

  /// Thêm index cho các bảng
  Future<void> _addIndexes(Migrator m) async {
    try {
      // WaterIntakeHistoryTable
      await m.createIndex(Index(
        'idx_water_intake_history_date',
        'CREATE INDEX idx_water_intake_history_date ON water_intake_history_table (date)',
      ));

      // WaterIntakeEntryTable
      await m.createIndex(Index(
        'idx_water_intake_entry_history_id',
        'CREATE INDEX idx_water_intake_entry_history_id ON water_intake_entry_table (history_id)',
      ));
      await m.createIndex(Index(
        'idx_water_intake_entry_timestamp',
        'CREATE INDEX idx_water_intake_entry_timestamp ON water_intake_entry_table (timestamp)',
      ));
    } catch (e) {
      debugPrint('Error adding indexes: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error adding indexes');
    }
  }

  /// Thêm ràng buộc cho các trường dữ liệu
  Future<void> _addConstraints(Migrator m) async {
    try {
      // Các ràng buộc sẽ được tự động thêm khi tạo bảng mới
      // Không thể thêm ràng buộc cho bảng đã tồn tại trong SQLite
      // Cần tạo bảng mới và di chuyển dữ liệu nếu muốn thêm ràng buộc
    } catch (e) {
      debugPrint('Error adding constraints: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error adding constraints');
    }
  }

  /// Kiểm tra tính toàn vẹn của cơ sở dữ liệu
  Future<void> validateDatabaseIntegrity() async {
    try {
      final result = await customSelect('PRAGMA integrity_check').get();
      if (result.isNotEmpty && result.first.data['integrity_check'] != 'ok') {
        AppLogger.warning('Database integrity check failed: ${result.first.data['integrity_check']}');
      } else {
        AppLogger.info('Database integrity check passed');
      }
    } catch (e) {
      debugPrint('Error validating database integrity: $e');
      AppLogger.reportError(e, StackTrace.current, 'Error validating database integrity');
    }
  }

  /// Lấy lịch sử uống nước theo ngày
  Future<WaterIntakeHistoryTableData?> getWaterIntakeHistoryByDate(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final query = select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.date.equals(dateString));
      return await query.getSingleOrNull();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history by date');
      rethrow;
    }
  }

  /// Lấy tất cả lịch sử uống nước
  Future<List<WaterIntakeHistoryTableData>> getAllWaterIntakeHistory({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = select(waterIntakeHistoryTable);

      // Thêm điều kiện lọc theo ngày nếu có
      if (startDate != null) {
        final startDateString = startDate.toIso8601String().split('T')[0];
        query.where((tbl) => tbl.date.isBiggerOrEqualValue(startDateString));
      }
      if (endDate != null) {
        final endDateString = endDate.toIso8601String().split('T')[0];
        query.where((tbl) => tbl.date.isSmallerOrEqualValue(endDateString));
      }

      // Sắp xếp theo ngày giảm dần (mới nhất trước)
      query.orderBy([(t) => OrderingTerm.desc(t.date)]);

      // Thêm phân trang nếu có
      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting all water intake history');
      rethrow;
    }
  }

  /// Lấy các lần uống nước theo historyId
  Future<List<WaterIntakeEntryTableData>> getEntriesByHistoryId(
    String historyId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final query = select(waterIntakeEntryTable)
        ..where((tbl) => tbl.historyId.equals(historyId))
        ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);

      // Thêm phân trang nếu có
      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting entries by history ID');
      rethrow;
    }
  }

  /// Thêm hoặc cập nhật lịch sử uống nước
  Future<void> insertOrUpdateWaterIntakeHistory(WaterIntakeHistoryTableCompanion history) async {
    try {
      await into(waterIntakeHistoryTable).insertOnConflictUpdate(history);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error inserting or updating water intake history');
      rethrow;
    }
  }

  /// Thêm lần uống nước mới
  Future<void> insertWaterIntakeEntry(WaterIntakeEntryTableCompanion entry) async {
    try {
      await into(waterIntakeEntryTable).insert(entry);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error inserting water intake entry');
      rethrow;
    }
  }

  /// Xóa lần uống nước
  Future<void> deleteWaterIntakeEntry(String entryId) async {
    try {
      await (delete(waterIntakeEntryTable)..where((tbl) => tbl.id.equals(entryId))).go();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting water intake entry');
      rethrow;
    }
  }

  /// Xóa tất cả lịch sử uống nước
  Future<void> clearAllWaterIntakeHistory() async {
    try {
      await transaction(() async {
        await delete(waterIntakeEntryTable).go();
        await delete(waterIntakeHistoryTable).go();
      });
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing all water intake history');
      rethrow;
    }
  }

  /// Xóa lịch sử uống nước cũ hơn một ngày cụ thể
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];

      // Lấy danh sách các historyId cần xóa
      final query = select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.date.isSmallerThanValue(dateString));
      final historyToDelete = await query.get();

      await transaction(() async {
        // Xóa các entry trước
        for (final history in historyToDelete) {
          await (delete(waterIntakeEntryTable)..where((tbl) => tbl.historyId.equals(history.id))).go();
        }

        // Sau đó xóa các history
        await (delete(waterIntakeHistoryTable)..where((tbl) => tbl.date.isSmallerThanValue(dateString))).go();
      });
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error deleting old water intake history');
      rethrow;
    }
  }

  // ----------------------
  // User Data Methods
  // ----------------------

  /// Lấy dữ liệu người dùng
  Future<UserDataTableData?> getUserData() async {
    try {
      final query = select(userDataTable)
        ..where((tbl) => tbl.id.equals('current_user'));
      return await query.getSingleOrNull();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user data');
      rethrow;
    }
  }

  /// Lưu hoặc cập nhật dữ liệu người dùng
  Future<void> saveUserData(UserDataTableCompanion userData) async {
    try {
      await into(userDataTable).insertOnConflictUpdate(userData);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user data');
      rethrow;
    }
  }

  /// Xóa dữ liệu người dùng
  Future<void> clearUserData() async {
    try {
      await (delete(userDataTable)..where((tbl) => tbl.id.equals('current_user'))).go();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing user data');
      rethrow;
    }
  }

  // ----------------------
  // Reminder Settings Methods
  // ----------------------

  /// Lấy cài đặt nhắc nhở
  Future<ReminderSettingsTableData?> getReminderSettings() async {
    try {
      final query = select(reminderSettingsTable)
        ..where((tbl) => tbl.id.equals('water_reminder'));
      return await query.getSingleOrNull();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting reminder settings');
      rethrow;
    }
  }

  /// Lưu hoặc cập nhật cài đặt nhắc nhở
  Future<void> saveReminderSettings(ReminderSettingsTableCompanion settings) async {
    try {
      await into(reminderSettingsTable).insertOnConflictUpdate(settings);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving reminder settings');
      rethrow;
    }
  }

  /// Xóa cài đặt nhắc nhở
  Future<void> clearReminderSettings() async {
    try {
      await (delete(reminderSettingsTable)..where((tbl) => tbl.id.equals('water_reminder'))).go();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error clearing reminder settings');
      rethrow;
    }
  }
}

/// Mở kết nối đến cơ sở dữ liệu
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'water_mind.sqlite'));

      // Tạo thư mục nếu chưa tồn tại
      if (!dbFolder.existsSync()) {
        dbFolder.createSync(recursive: true);
      }

      // Sử dụng mã hóa cho cơ sở dữ liệu
      // Lưu ý: Trong môi trường thực tế, khóa mã hóa nên được lưu trữ an toàn
      // và không nên hard-code trong mã nguồn
      // const encryptionKey = 'water_mind_secure_key_2023';

      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          // Bật tính năng WAL (Write-Ahead Logging) để cải thiện hiệu suất
          db.execute('PRAGMA journal_mode=WAL');

          // Bật tính năng foreign keys để đảm bảo tính toàn vẹn tham chiếu
          db.execute('PRAGMA foreign_keys=ON');

          // Thiết lập timeout cho các truy vấn (5 giây)
          db.execute('PRAGMA busy_timeout=5000');
        },
      );
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error opening database connection');
      rethrow;
    }
  });
}
