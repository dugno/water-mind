import 'package:drift/drift.dart';

/// Bảng lưu trữ lịch sử uống nước theo ngày
class WaterIntakeHistoryTable extends Table {
  /// ID của lịch sử uống nước (dựa trên ngày)
  TextColumn get id => text()();
  
  /// Ngày của lịch sử uống nước (định dạng ISO8601)
  TextColumn get date => text()();
  
  /// Mục tiêu uống nước hàng ngày (ml hoặc fl oz)
  RealColumn get dailyGoal => real()();
  
  /// Đơn vị đo lường (0: metric, 1: imperial)
  IntColumn get measureUnit => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Bảng lưu trữ các lần uống nước
class WaterIntakeEntryTable extends Table {
  /// ID duy nhất của lần uống nước
  TextColumn get id => text()();
  
  /// ID của lịch sử uống nước mà lần uống nước này thuộc về
  TextColumn get historyId => text().references(WaterIntakeHistoryTable, #id)();
  
  /// Thời gian uống nước (định dạng ISO8601)
  TextColumn get timestamp => text()();
  
  /// Lượng nước uống (ml hoặc fl oz)
  RealColumn get amount => real()();
  
  /// Loại đồ uống (0: water, 1: coffee, ...)
  IntColumn get drinkTypeId => integer()();
  
  /// Ghi chú (có thể null)
  TextColumn get note => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
