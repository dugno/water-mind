import 'package:drift/drift.dart';
import 'package:water_mind/src/core/database/converters/type_converters.dart';

/// Bảng lưu trữ lịch sử uống nước theo ngày
class WaterIntakeHistoryTable extends Table {
  /// ID của lịch sử uống nước (dựa trên ngày)
  TextColumn get id => text()();

  /// Ngày của lịch sử uống nước (định dạng ISO8601)
  TextColumn get date => text().map(const DateTimeConverter())();

  /// Mục tiêu uống nước hàng ngày (ml hoặc fl oz)
  RealColumn get dailyGoal => real()();

  /// Đơn vị đo lường (0: metric, 1: imperial)
  IntColumn get measureUnit => integer().map(const MeasureUnitConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (daily_goal > 0)',
  ];

  List<Index> get indexes => [
    Index(
      'idx_water_intake_history_date',
      'CREATE INDEX idx_water_intake_history_date ON water_intake_history_table (date)',
    ),
  ];
}

/// Bảng lưu trữ các lần uống nước
class WaterIntakeEntryTable extends Table {
  /// ID duy nhất của lần uống nước
  TextColumn get id => text()();

  /// ID của lịch sử uống nước mà lần uống nước này thuộc về
  TextColumn get historyId => text().references(WaterIntakeHistoryTable, #id)();

  /// Thời gian uống nước (định dạng ISO8601)
  TextColumn get timestamp => text().map(const DateTimeConverter())();

  /// Lượng nước uống (ml hoặc fl oz)
  RealColumn get amount => real()();

  /// Loại đồ uống (0: water, 1: coffee, ...)
  IntColumn get drinkTypeId => integer()();

  /// Ghi chú (có thể null)
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (amount > 0)',
  ];

  List<Index> get indexes => [
    Index(
      'idx_water_intake_entry_history_id',
      'CREATE INDEX idx_water_intake_entry_history_id ON water_intake_entry_table (history_id)',
    ),
    Index(
      'idx_water_intake_entry_timestamp',
      'CREATE INDEX idx_water_intake_entry_timestamp ON water_intake_entry_table (timestamp)',
    ),
  ];
}

/// Bảng lưu trữ thông tin người dùng
class UserDataTable extends Table {
  /// ID duy nhất của người dùng (mặc định là 'current_user')
  TextColumn get id => text()();

  /// Giới tính (0: male, 1: female, 2: other)
  IntColumn get gender => integer().nullable().map(const GenderConverter())();

  /// Chiều cao (cm hoặc inch)
  RealColumn get height => real().nullable()();

  /// Cân nặng (kg hoặc lb)
  RealColumn get weight => real().nullable()();

  /// Đơn vị đo lường (0: metric, 1: imperial)
  IntColumn get measureUnit => integer().map(const MeasureUnitConverter())();

  /// Ngày sinh (định dạng ISO8601)
  TextColumn get dateOfBirth => text().nullable().map(const DateTimeConverter())();

  /// Mức độ hoạt động (0: sedentary, 1: lightlyActive, ...)
  IntColumn get activityLevel => integer().nullable().map(const ActivityLevelConverter())();

  /// Môi trường sống (0: hot, 1: moderate, 2: cold)
  IntColumn get livingEnvironment => integer().nullable().map(const LivingEnvironmentConverter())();

  /// Thời gian thức dậy (định dạng HH:MM)
  TextColumn get wakeUpTime => text().nullable().map(const TimeOfDayConverter())();

  /// Thời gian đi ngủ (định dạng HH:MM)
  TextColumn get bedTime => text().nullable().map(const TimeOfDayConverter())();

  /// Thời gian cập nhật cuối cùng (định dạng ISO8601)
  TextColumn get lastUpdated => text().map(const DateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (height IS NULL OR height > 0)',
    'CHECK (weight IS NULL OR weight > 0)',
  ];
}

/// Bảng lưu trữ cài đặt nhắc nhở uống nước
class ReminderSettingsTable extends Table {
  /// ID duy nhất của cài đặt nhắc nhở (mặc định là 'water_reminder')
  TextColumn get id => text()();

  /// Trạng thái bật/tắt nhắc nhở
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Chế độ nhắc nhở (0: standard, 1: interval, 2: custom)
  IntColumn get mode => integer().withDefault(const Constant(0))();

  /// Thời gian thức dậy (định dạng HH:MM)
  TextColumn get wakeUpTime => text().map(const TimeOfDayConverter())();

  /// Thời gian đi ngủ (định dạng HH:MM)
  TextColumn get bedTime => text().map(const TimeOfDayConverter())();

  /// Khoảng thời gian nhắc nhở (phút)
  IntColumn get intervalMinutes => integer().withDefault(const Constant(60))();

  /// Thời gian tùy chỉnh (JSON string của danh sách thời gian)
  TextColumn get customTimes => text().withDefault(const Constant('[]'))
      .map(const TimeOfDayListConverter())();

  /// Thời gian tùy chỉnh bị vô hiệu hóa (JSON string của danh sách thời gian)
  TextColumn get disabledCustomTimes => text().withDefault(const Constant('[]'))
      .map(const TimeOfDayListConverter())();

  /// Thời gian nhắc nhở tiêu chuẩn (JSON string của danh sách thời gian)
  TextColumn get standardTimes => text().withDefault(const Constant('[]'))
      .map(const StandardReminderTimeListConverter())();

  /// Bỏ qua nhắc nhở nếu đã đạt mục tiêu
  BoolColumn get skipIfGoalMet => boolean().withDefault(const Constant(false))();

  /// Bật/tắt chế độ không làm phiền
  BoolColumn get enableDoNotDisturb => boolean().withDefault(const Constant(false))();

  /// Thời gian bắt đầu không làm phiền (định dạng HH:MM)
  TextColumn get doNotDisturbStart => text().nullable().map(const TimeOfDayConverter())();

  /// Thời gian kết thúc không làm phiền (định dạng HH:MM)
  TextColumn get doNotDisturbEnd => text().nullable().map(const TimeOfDayConverter())();

  /// Thời gian cập nhật cuối cùng (định dạng ISO8601)
  TextColumn get lastUpdated => text().map(const DateTimeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (interval_minutes > 0)',
  ];
}
