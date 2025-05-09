# Drift Database Implementation

## Tổng quan

Drift là một thư viện ORM (Object-Relational Mapping) cho SQLite trong Flutter, giúp tạo ra các truy vấn type-safe và tự động tạo code cho các bảng và truy vấn.

## Cấu trúc thư mục

```
lib/src/core/database/
├── converters/                # TypeConverter cho các kiểu dữ liệu phức tạp
│   └── type_converters.dart   # Các TypeConverter
├── daos/                      # Data Access Objects
│   ├── reminder_settings_dao.dart  # DAO cho cài đặt nhắc nhở
│   ├── user_data_dao.dart     # DAO cho dữ liệu người dùng
│   └── water_intake_dao.dart  # DAO cho dữ liệu uống nước
├── providers/                 # Riverpod providers
│   └── database_providers.dart # Các provider cho database
├── utils/                     # Các tiện ích
│   ├── database_cleanup_service.dart # Dịch vụ xóa dữ liệu cũ
│   ├── database_generator.dart # Tiện ích tạo cơ sở dữ liệu mới
│   └── database_service.dart  # Dịch vụ quản lý cơ sở dữ liệu
├── database.dart              # Định nghĩa cơ sở dữ liệu
├── database.g.dart            # File được tạo tự động bởi Drift
├── database_initializer.dart  # Khởi tạo cơ sở dữ liệu
└── tables.dart                # Định nghĩa các bảng
```

## Các bảng dữ liệu

### WaterIntakeHistoryTable
Lưu trữ lịch sử uống nước theo ngày.

### WaterIntakeEntryTable
Lưu trữ các lần uống nước.

### UserDataTable
Lưu trữ thông tin người dùng.

### ReminderSettingsTable
Lưu trữ cài đặt nhắc nhở uống nước.

## Cách sử dụng

### Khởi tạo cơ sở dữ liệu

```dart
// Trong main.dart
final databaseService = DatabaseService();
await databaseService.initialize(
  daysToKeep: 90, // Giữ dữ liệu 90 ngày
  enableCleanup: true,
  runCleanupImmediately: false,
);
```

### Sử dụng các provider

```dart
// Sử dụng provider cho database
final database = ref.watch(databaseProvider);

// Sử dụng provider cho DAO
final waterIntakeDao = ref.watch(waterIntakeDaoProvider);
final userDataDao = ref.watch(userDataDaoProvider);
final reminderSettingsDao = ref.watch(reminderSettingsDaoProvider);

// Sử dụng provider cho repository
final waterIntakeRepository = ref.watch(waterIntakeRepositoryProvider);
final userRepository = ref.watch(userRepositoryProvider);
final reminderRepository = ref.watch(reminderRepositoryProvider);

// Sử dụng provider cho dữ liệu
final waterIntakeHistory = ref.watch(waterIntakeHistoryProvider(date));
final allWaterIntakeHistory = ref.watch(allWaterIntakeHistoryProvider);
final userData = ref.watch(userDataProvider);
final reminderSettings = ref.watch(reminderSettingsProvider);
```

### Sử dụng các repository

```dart
// Lấy dữ liệu
final waterIntakeHistory = await waterIntakeRepository.getWaterIntakeHistory(date);
final userData = await userRepository.getUserData();
final reminderSettings = await reminderRepository.getReminderSettings();

// Lưu dữ liệu
await waterIntakeRepository.saveWaterIntakeHistory(history);
await userRepository.saveUserData(userData);
await reminderRepository.saveReminderSettings(settings);

// Xóa dữ liệu
await waterIntakeRepository.clearAllWaterIntakeHistory();
await userRepository.clearUserData();
await reminderRepository.clearReminderSettings();
```

## Các tính năng nâng cao

### TypeConverter

TypeConverter giúp chuyển đổi giữa các kiểu dữ liệu phức tạp và kiểu dữ liệu cơ bản mà SQLite hỗ trợ.

```dart
// Sử dụng TypeConverter trong định nghĩa bảng
TextColumn get wakeUpTime => text().map(const TimeOfDayConverter())();
```

### Migration

Migration giúp nâng cấp schema của cơ sở dữ liệu khi có thay đổi.

```dart
// Trong database.dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Nâng cấp từ phiên bản 1 lên 2
      if (from < 2 && to >= 2) {
        await m.createTable(userDataTable);
        await m.createTable(reminderSettingsTable);
      }
    },
  );
}
```

### Xử lý lỗi

Tất cả các phương thức trong DAO và Repository đều có xử lý lỗi để đảm bảo tính ổn định của ứng dụng.

```dart
try {
  // Thực hiện truy vấn
} catch (e) {
  AppLogger.reportError(e, StackTrace.current, 'Error message');
  rethrow;
}
```

### Tự động xóa dữ liệu cũ

Dịch vụ `DatabaseCleanupService` giúp tự động xóa dữ liệu cũ để tránh cơ sở dữ liệu phình to theo thời gian.

```dart
final cleanupService = DatabaseCleanupService();
cleanupService.initialize(daysToKeep: 90);
```

## Các lưu ý

- Luôn sử dụng các provider để truy cập vào cơ sở dữ liệu thay vì truy cập trực tiếp.
- Sử dụng transaction khi thực hiện nhiều thao tác liên quan đến nhau để đảm bảo tính toàn vẹn của dữ liệu.
- Đảm bảo đóng cơ sở dữ liệu khi ứng dụng kết thúc để tránh rò rỉ bộ nhớ.
