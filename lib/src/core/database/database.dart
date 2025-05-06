import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:water_mind/src/core/database/tables.dart';

part 'database.g.dart';

/// Cơ sở dữ liệu chính của ứng dụng
@DriftDatabase(tables: [
  WaterIntakeHistoryTable,
  WaterIntakeEntryTable,
])
class AppDatabase extends _$AppDatabase {
  /// Constructor
  AppDatabase() : super(_openConnection());

  /// Phiên bản cơ sở dữ liệu
  @override
  int get schemaVersion => 1;

  /// Xử lý nâng cấp cơ sở dữ liệu
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Xử lý nâng cấp trong tương lai
      },
    );
  }

  /// Lấy lịch sử uống nước theo ngày
  Future<WaterIntakeHistoryTableData?> getWaterIntakeHistoryByDate(DateTime date) {
    final dateString = date.toIso8601String().split('T')[0];
    final query = select(waterIntakeHistoryTable)
      ..where((tbl) => tbl.date.equals(dateString));
    return query.getSingleOrNull();
  }

  /// Lấy tất cả lịch sử uống nước
  Future<List<WaterIntakeHistoryTableData>> getAllWaterIntakeHistory() {
    return select(waterIntakeHistoryTable).get();
  }

  /// Lấy các lần uống nước theo historyId
  Future<List<WaterIntakeEntryTableData>> getEntriesByHistoryId(String historyId) {
    final query = select(waterIntakeEntryTable)
      ..where((tbl) => tbl.historyId.equals(historyId))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
    return query.get();
  }

  /// Thêm hoặc cập nhật lịch sử uống nước
  Future<void> insertOrUpdateWaterIntakeHistory(WaterIntakeHistoryTableCompanion history) {
    return into(waterIntakeHistoryTable).insertOnConflictUpdate(history);
  }

  /// Thêm lần uống nước mới
  Future<void> insertWaterIntakeEntry(WaterIntakeEntryTableCompanion entry) {
    return into(waterIntakeEntryTable).insert(entry);
  }

  /// Xóa lần uống nước
  Future<void> deleteWaterIntakeEntry(String entryId) {
    return (delete(waterIntakeEntryTable)..where((tbl) => tbl.id.equals(entryId))).go();
  }

  /// Xóa tất cả lịch sử uống nước
  Future<void> clearAllWaterIntakeHistory() async {
    await delete(waterIntakeEntryTable).go();
    await delete(waterIntakeHistoryTable).go();
  }
}

/// Mở kết nối đến cơ sở dữ liệu
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'water_mind.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
