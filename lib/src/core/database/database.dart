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

  /// Phiên bản thêm bảng UserPreferencesTable và ForecastHydrationTable
  static const int addUserPreferencesAndForecastTables = 4;

  /// Phiên bản thêm bảng UserStreakTable
  static const int addUserStreakTable = 5;

  /// Phiên bản hiện tại
  static const int currentVersion = addUserStreakTable;
}

/// Cơ sở dữ liệu chính của ứng dụng
@DriftDatabase(tables: [
  WaterIntakeHistoryTable,
  WaterIntakeEntryTable,
  UserDataTable,
  ReminderSettingsTable,
  UserPreferencesTable,
  ForecastHydrationTable,
  UserStreakTable,
])
class AppDatabase extends _$AppDatabase {
  /// Constructor
  AppDatabase() : super(_openConnection());

  /// Constructor cho việc kiểm thử
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

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

        // Nâng cấp lên phiên bản 4 (thêm bảng UserPreferencesTable và ForecastHydrationTable)
        if (from < DatabaseVersions.addUserPreferencesAndForecastTables && to >= DatabaseVersions.addUserPreferencesAndForecastTables) {
          AppLogger.info('Adding user preferences and forecast hydration tables');

          // Tạo bảng UserPreferencesTable
          await customStatement('''
            CREATE TABLE user_preferences_table (
              id TEXT NOT NULL PRIMARY KEY,
              last_drink_type_id TEXT,
              last_drink_amount REAL,
              measure_unit INTEGER NOT NULL,
              last_updated TEXT NOT NULL
            )
          ''');

          // Tạo bảng ForecastHydrationTable
          await customStatement('''
            CREATE TABLE forecast_hydration_table (
              id TEXT NOT NULL PRIMARY KEY,
              date TEXT NOT NULL,
              recommended_water_intake REAL NOT NULL,
              weather_condition_code INTEGER NOT NULL,
              weather_description TEXT NOT NULL,
              max_temperature REAL NOT NULL,
              min_temperature REAL NOT NULL,
              measure_unit INTEGER NOT NULL,
              last_updated TEXT NOT NULL
            )
          ''');

          // Thêm index cho bảng ForecastHydrationTable
          await customStatement(
            'CREATE INDEX idx_forecast_hydration_date ON forecast_hydration_table (date)'
          );
        }

        // Nâng cấp lên phiên bản 5 (thêm bảng UserStreakTable)
        if (from < DatabaseVersions.addUserStreakTable && to >= DatabaseVersions.addUserStreakTable) {
          AppLogger.info('Adding user streak table');

          // Tạo bảng UserStreakTable
          await customStatement('''
            CREATE TABLE user_streak_table (
              id TEXT NOT NULL PRIMARY KEY,
              current_streak INTEGER NOT NULL DEFAULT 0,
              longest_streak INTEGER NOT NULL DEFAULT 0,
              last_active_date TEXT NOT NULL,
              last_updated TEXT NOT NULL
            )
          ''');
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
      // Chuẩn hóa ngày để đảm bảo chỉ có ngày, tháng, năm (không có giờ, phút, giây)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateString = normalizedDate.toIso8601String().split('T')[0];
      AppLogger.info('DATABASE: Getting water intake history for date: $dateString');

      // Thử tìm theo ID (dateString)
      final queryById = select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.id.equals(dateString));
      final resultById = await queryById.getSingleOrNull();

      if (resultById != null) {
        AppLogger.info('Found history by ID: ${resultById.id}, date: ${resultById.date}, dailyGoal: ${resultById.dailyGoal}');
        return resultById;
      }

      // Nếu không tìm thấy theo ID, thử tìm theo date
      AppLogger.info('No history found by ID, trying to find by date...');
      final queryByDate = select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.date.equals(dateString));
      final resultByDate = await queryByDate.getSingleOrNull();

      if (resultByDate != null) {
        AppLogger.info('Found history by date: ${resultByDate.id}, date: ${resultByDate.date}, dailyGoal: ${resultByDate.dailyGoal}');
        return resultByDate;
      }

      // Nếu vẫn không tìm thấy, thử tìm bằng SQL trực tiếp
      AppLogger.info('No history found by date, trying with direct SQL...');
      final results = await customSelect(
        'SELECT * FROM water_intake_history_table WHERE id = ? OR date = ?',
        variables: [Variable.withString(dateString), Variable.withString(dateString)],
        readsFrom: {waterIntakeHistoryTable},
      ).get();

      if (results.isNotEmpty) {
        final row = results.first;
        AppLogger.info('Found history with SQL: id=${row.data['id']}, date=${row.data['date']}');

        // Chuyển đổi từ row sang WaterIntakeHistoryTableData
        return WaterIntakeHistoryTableData(
          id: row.data['id'] as String,
          date: DateTime.parse(row.data['date'] as String),
          dailyGoal: row.data['daily_goal'] as double,
          measureUnit: MeasureUnit.values[row.data['measure_unit'] as int],
        );
      }

      AppLogger.info('No history found for date: $dateString');
      return null;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting water intake history by date: ${e.toString()}');
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
      // Log thông tin về companion
      AppLogger.info('History companion: id=${history.id.value}, date=${history.date.value}, dailyGoal=${history.dailyGoal.value}');

      // Kiểm tra xem bản ghi đã tồn tại chưa
      final existing = await (select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.id.equals(history.id.value)))
        .getSingleOrNull();

      AppLogger.info('Checking history record: ${history.id.value}, exists: ${existing != null}');

      if (existing != null) {
        // Nếu đã tồn tại, sử dụng update
        final updateCompanion = WaterIntakeHistoryTableCompanion(
          dailyGoal: history.dailyGoal,
          measureUnit: history.measureUnit,
        );
        final updateResult = await (update(waterIntakeHistoryTable)
          ..where((tbl) => tbl.id.equals(history.id.value)))
          .write(updateCompanion);
        AppLogger.info('Updated water intake history, result: $updateResult');
      } else {
        // Nếu chưa tồn tại, sử dụng insert
        final insertResult = await into(waterIntakeHistoryTable).insert(history);
        AppLogger.info('Inserted water intake history, result: $insertResult');
      }

      // Kiểm tra lại sau khi thêm/cập nhật
      final afterOperation = await (select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.id.equals(history.id.value)))
        .getSingleOrNull();

      final success = afterOperation != null;
      AppLogger.info('Record exists after operation: $success, id: ${history.id.value}');

      if (!success) {
        AppLogger.warning('Failed to insert/update history record: ${history.id.value}');

        // Thử thêm lại với SQL trực tiếp
        await customStatement(
          'INSERT OR REPLACE INTO water_intake_history_table (id, date, daily_goal, measure_unit) VALUES (?, ?, ?, ?)',
          [history.id.value, history.date.value.toIso8601String(), history.dailyGoal.value, history.measureUnit.value.index]
        );

        // Kiểm tra lại
        final afterCustomInsert = await (select(waterIntakeHistoryTable)
          ..where((tbl) => tbl.id.equals(history.id.value)))
          .getSingleOrNull();

        if (afterCustomInsert != null) {
          AppLogger.info('Record exists after custom insert: id=${afterCustomInsert.id}');
        } else {
          AppLogger.warning('Record still does not exist after custom insert');
        }
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error inserting or updating water intake history: ${e.toString()}');
      rethrow;
    }
  }

  /// Thêm lần uống nước mới
  Future<int> insertWaterIntakeEntry(WaterIntakeEntryTableCompanion entry) async {
    try {
      AppLogger.info('Inserting water intake entry: id=${entry.id.value}, historyId=${entry.historyId.value}, amount=${entry.amount.value}');

      // Kiểm tra xem historyId có tồn tại không
      final historyExists = await (select(waterIntakeHistoryTable)
        ..where((tbl) => tbl.id.equals(entry.historyId.value)))
        .getSingleOrNull();

      if (historyExists == null) {
        AppLogger.warning('History record not found for historyId: ${entry.historyId.value}');
        throw Exception('History record not found for historyId: ${entry.historyId.value}');
      }

      // Thêm entry mới
      final result = await into(waterIntakeEntryTable).insert(entry);
      AppLogger.info('Inserted water intake entry, result: $result');

      // Kiểm tra xem entry đã được thêm thành công chưa
      final entryExists = await (select(waterIntakeEntryTable)
        ..where((tbl) => tbl.id.equals(entry.id.value)))
        .getSingleOrNull();

      final success = entryExists != null;
      AppLogger.info('Entry exists after insertion: $success, id: ${entry.id.value}');

      return result;
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

  /// Phương thức này được giữ lại để tương thích với mã hiện có
  /// nhưng không còn thực hiện xóa dữ liệu
  Future<void> deleteWaterIntakeHistoryOlderThan(DateTime date) async {
    // Không làm gì cả, giữ lại tất cả dữ liệu
    AppLogger.info('Database cleanup disabled. All water intake history will be kept for the entire app lifecycle.');
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
    final result =  await into(reminderSettingsTable).insertOnConflictUpdate(settings);
    debugPrint(result.toString());
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

  // ----------------------
  // User Preferences Methods
  // ----------------------

  /// Lấy tùy chọn người dùng
  Future<UserPreferencesTableData?> getUserPreferences() async {
    try {
      final query = select(userPreferencesTable)
        ..where((tbl) => tbl.id.equals('user_preferences'));
      return await query.getSingleOrNull();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user preferences');
      rethrow;
    }
  }

  /// Lưu hoặc cập nhật tùy chọn người dùng
  Future<void> saveUserPreferences(UserPreferencesTableCompanion preferences) async {
    try {
      await into(userPreferencesTable).insertOnConflictUpdate(preferences);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user preferences');
      rethrow;
    }
  }

  /// Cập nhật thông tin uống nước gần nhất
  Future<void> updateLastDrinkInfo(String drinkTypeId, double amount) async {
    try {
      // Lấy đơn vị đo lường từ dữ liệu người dùng hoặc sử dụng mặc định
      final userData = await getUserData();
      final measureUnit = userData?.measureUnit ?? MeasureUnit.metric;

      // Tạo companion để cập nhật hoặc chèn mới
      final companion = UserPreferencesTableCompanion(
        id: const Value('user_preferences'),
        lastDrinkTypeId: Value(drinkTypeId),
        lastDrinkAmount: Value(amount),
        measureUnit: Value(measureUnit),
        lastUpdated: Value(DateTime.now()),
      );

      await saveUserPreferences(companion);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating last drink info');
      rethrow;
    }
  }

  // ----------------------
  // User Streak Methods
  // ----------------------

  /// Lấy thông tin streak của người dùng
  Future<UserStreakTableData?> getUserStreak() async {
    try {
      final query = select(userStreakTable)
        ..where((tbl) => tbl.id.equals('user_streak'));
      return await query.getSingleOrNull();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting user streak');
      rethrow;
    }
  }

  /// Lưu hoặc cập nhật thông tin streak của người dùng
  Future<void> saveUserStreak(UserStreakTableCompanion streak) async {
    try {
      await into(userStreakTable).insertOnConflictUpdate(streak);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving user streak');
      rethrow;
    }
  }

  /// Cập nhật streak khi người dùng uống nước
  Future<void> updateUserStreak(DateTime activityDate) async {
    try {
      // Lấy thông tin streak hiện tại
      final currentStreak = await getUserStreak();

      // Nếu chưa có thông tin streak, tạo mới với streak = 1
      if (currentStreak == null) {
        final newStreak = UserStreakTableCompanion(
          id: const Value('user_streak'),
          currentStreak: const Value(1),
          longestStreak: const Value(1),
          lastActiveDate: Value(activityDate),
          lastUpdated: Value(DateTime.now()),
        );
        await saveUserStreak(newStreak);
        return;
      }

      // Chuẩn hóa ngày để so sánh (chỉ lấy ngày, tháng, năm)
      final normalizedActivityDate = DateTime(activityDate.year, activityDate.month, activityDate.day);
      final normalizedLastActiveDate = DateTime(
        currentStreak.lastActiveDate.year,
        currentStreak.lastActiveDate.month,
        currentStreak.lastActiveDate.day,
      );

      // Tính số ngày chênh lệch
      final difference = normalizedActivityDate.difference(normalizedLastActiveDate).inDays;

      // Xác định streak mới
      int newCurrentStreak = currentStreak.currentStreak;
      int newLongestStreak = currentStreak.longestStreak;

      // Nếu là ngày hôm nay, không thay đổi streak
      if (difference == 0) {
        // Không thay đổi streak, chỉ cập nhật thời gian
        await saveUserStreak(UserStreakTableCompanion(
          id: const Value('user_streak'),
          currentStreak: Value(currentStreak.currentStreak),
          longestStreak: Value(currentStreak.longestStreak),
          lastActiveDate: Value(currentStreak.lastActiveDate),
          lastUpdated: Value(DateTime.now()),
        ));
        return;
      }

      // Nếu là ngày tiếp theo, tăng streak
      if (difference == 1) {
        newCurrentStreak += 1;
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
        }
      }
      // Nếu là ngày trong quá khứ, không thay đổi streak
      else if (difference < 0) {
        // Không thay đổi streak, chỉ cập nhật thời gian
        await saveUserStreak(UserStreakTableCompanion(
          id: const Value('user_streak'),
          currentStreak: Value(currentStreak.currentStreak),
          longestStreak: Value(currentStreak.longestStreak),
          lastActiveDate: Value(currentStreak.lastActiveDate),
          lastUpdated: Value(DateTime.now()),
        ));
        return;
      }
      // Nếu bỏ lỡ nhiều ngày, reset streak
      else {
        newCurrentStreak = 1;
      }

      // Cập nhật streak
      await saveUserStreak(UserStreakTableCompanion(
        id: const Value('user_streak'),
        currentStreak: Value(newCurrentStreak),
        longestStreak: Value(newLongestStreak),
        lastActiveDate: Value(normalizedActivityDate),
        lastUpdated: Value(DateTime.now()),
      ));
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating user streak');
      rethrow;
    }
  }

  // ----------------------
  // Forecast Hydration Methods
  // ----------------------

  /// Lấy dự báo lượng nước cho một ngày cụ thể
  Future<ForecastHydrationTableData?> getForecastHydration(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final query = select(forecastHydrationTable)
        ..where((tbl) => tbl.id.equals(dateString));
      return await query.getSingleOrNull();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration');
      rethrow;
    }
  }

  /// Lấy dự báo lượng nước cho nhiều ngày
  Future<List<ForecastHydrationTableData>> getForecastHydrationRange(
    DateTime startDate,
    int days,
  ) async {
    try {
      final result = <ForecastHydrationTableData>[];
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateString = date.toIso8601String().split('T')[0];
        final query = select(forecastHydrationTable)
          ..where((tbl) => tbl.id.equals(dateString));
        final forecast = await query.getSingleOrNull();
        if (forecast != null) {
          result.add(forecast);
        }
      }
      return result;
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting forecast hydration range');
      rethrow;
    }
  }

  /// Lưu hoặc cập nhật dự báo lượng nước
  Future<void> saveForecastHydration(ForecastHydrationTableCompanion forecast) async {
    try {
      await into(forecastHydrationTable).insertOnConflictUpdate(forecast);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error saving forecast hydration');
      rethrow;
    }
  }

  /// Phương thức này được giữ lại để tương thích với mã hiện có
  /// nhưng không còn thực hiện xóa dữ liệu
  Future<int> deleteForecastHydrationOlderThan(DateTime date) async {
    // Không làm gì cả, giữ lại tất cả dữ liệu
    AppLogger.info('Database cleanup disabled. All forecast hydration data will be kept for the entire app lifecycle.');
    return 0; // Trả về 0 để chỉ ra rằng không có bản ghi nào bị xóa
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
