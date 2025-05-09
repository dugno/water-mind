# Key-Value Storage trong Water Mind

Ứng dụng Water Mind sử dụng SharedPreferences để lưu trữ các dữ liệu đơn giản, cài đặt và trạng thái ứng dụng. Lớp `KVStoreService` cung cấp một giao diện thống nhất để truy cập và quản lý các dữ liệu này.

**Lưu ý quan trọng**: Dữ liệu người dùng và cài đặt nhắc nhở đã được chuyển sang cơ sở dữ liệu Drift để nhất quán với các dữ liệu khác trong ứng dụng. Xem `UserRepositoryImpl` và `WaterReminderService` để biết thêm chi tiết.

## Cấu trúc

```
lib/src/core/services/kv_store/
├── kv_store.dart         # Service chính cho SharedPreferences (dữ liệu đơn giản)
└── README.md             # Tài liệu hướng dẫn

lib/src/core/database/    # Cơ sở dữ liệu Drift (dữ liệu phức tạp)
├── database.dart         # Định nghĩa cơ sở dữ liệu
├── tables.dart           # Định nghĩa các bảng
└── daos/                 # Data Access Objects
    ├── user_data_dao.dart       # DAO cho dữ liệu người dùng
    └── reminder_settings_dao.dart # DAO cho cài đặt nhắc nhở
```

## Dữ liệu được lưu trữ

### 1. Trạng thái ứng dụng
- **doneGettingStarted**: Đã hoàn thành màn hình giới thiệu hay chưa

### 2. Thông tin người dùng (Đã chuyển sang Drift)
- Dữ liệu người dùng đã được chuyển sang cơ sở dữ liệu Drift
- Xem `UserRepositoryImpl` trong `lib/src/core/services/user/user_repository.dart`

### 3. Cài đặt giao diện
- **themeStyle**: Kiểu giao diện (index)

### 4. Cache dữ liệu thời tiết
- **weatherCache**: Dữ liệu thời tiết (JSON string)
- **lastWeatherUpdate**: Thời gian cập nhật thời tiết gần nhất

### 5. Cài đặt nhắc nhở (Đã chuyển sang Drift)
- Cài đặt nhắc nhở uống nước đã được chuyển sang cơ sở dữ liệu Drift
- Xem `WaterReminderService` trong `lib/src/core/services/reminders/water_reminder_service.dart`

### 6. Cài đặt ứng dụng
- **appLanguage**: Ngôn ngữ ứng dụng
- **notificationsEnabled**: Trạng thái bật/tắt thông báo

### 7. Thông tin đồng bộ
- **lastSyncTime**: Thời gian đồng bộ gần nhất

## Cách sử dụng

### Khởi tạo

```dart
void main() async {
  // ...
  await KVStoreService.init();
  // ...
}
```

### Trạng thái ứng dụng

```dart
// Kiểm tra đã hoàn thành màn hình giới thiệu chưa
final isDone = KVStoreService.doneGettingStarted;

// Đặt trạng thái hoàn thành
await KVStoreService.setDoneGettingStarted(true);
```

### Thông tin người dùng (Đã chuyển sang Drift)

```dart
// Sử dụng UserRepository để truy cập dữ liệu người dùng
final userRepository = ref.watch(userRepositoryProvider);

// Lấy dữ liệu người dùng
final userData = await userRepository.getUserData();

// Lưu dữ liệu người dùng
await userRepository.saveUserData(userData);
```

### Cài đặt giao diện

```dart
// Lấy kiểu giao diện
final themeStyle = KVStoreService.getThemeStyle();

// Đặt kiểu giao diện
await KVStoreService.setThemeStyle(AppThemeStyle.dark);
```

### Cache dữ liệu thời tiết

```dart
// Lấy dữ liệu thời tiết
final weatherJson = KVStoreService.weatherCacheJson;
final weatherData = weatherJson != null
    ? WeatherData.fromJson(json.decode(weatherJson))
    : null;

// Lưu dữ liệu thời tiết
final jsonData = json.encode(weatherData.toJson());
await KVStoreService.setWeatherCacheJson(jsonData);

// Lấy thời gian cập nhật gần nhất
final lastUpdate = KVStoreService.lastWeatherUpdate;

// Đặt thời gian cập nhật
await KVStoreService.setLastWeatherUpdate(DateTime.now().millisecondsSinceEpoch);

// Xóa cache thời tiết
await KVStoreService.clearWeatherCache();
```

### Cài đặt nhắc nhở (Đã chuyển sang Drift)

```dart
// Sử dụng ReminderService để truy cập cài đặt nhắc nhở
final reminderService = ref.watch(reminderServiceProvider);

// Lấy cài đặt nhắc nhở
final reminderSettings = await reminderService.getReminderSettings();

// Lưu cài đặt nhắc nhở
await reminderService.saveReminderSettings(reminderSettings);

// Bật/tắt nhắc nhở
await reminderService.setRemindersEnabled(true);

// Đặt chế độ nhắc nhở
await reminderService.setReminderMode(ReminderMode.standard);
```

### Cài đặt ứng dụng

```dart
// Lấy ngôn ngữ ứng dụng
final language = KVStoreService.appLanguage;

// Đặt ngôn ngữ ứng dụng
await KVStoreService.setAppLanguage('vi');

// Lấy trạng thái thông báo
final notificationsEnabled = KVStoreService.notificationsEnabled;

// Đặt trạng thái thông báo
await KVStoreService.setNotificationsEnabled(true);
```

### Phương thức chung

```dart
// Xóa tất cả dữ liệu
await KVStoreService.clearAll();

// Lấy thời gian đồng bộ gần nhất
final lastSync = KVStoreService.lastSyncTime;

// Đặt thời gian đồng bộ
await KVStoreService.setLastSyncTime(DateTime.now().millisecondsSinceEpoch);
```

## Nguyên tắc thiết kế

Thiết kế lưu trữ dữ liệu trong ứng dụng tuân thủ các nguyên tắc SOLID và DRY:

1. **Single Responsibility**:
   - KVStoreService chỉ chịu trách nhiệm cho việc lưu trữ và truy xuất dữ liệu đơn giản từ SharedPreferences
   - Các DAO chỉ chịu trách nhiệm cho việc lưu trữ và truy xuất dữ liệu phức tạp từ Drift

2. **Open/Closed**:
   - Có thể mở rộng thêm các phương thức mới mà không cần sửa đổi các phương thức hiện có
   - Có thể thêm các bảng mới vào cơ sở dữ liệu mà không ảnh hưởng đến các bảng hiện có

3. **Liskov Substitution**:
   - Các repository tuân thủ interface đã định nghĩa, cho phép thay đổi implementation mà không ảnh hưởng đến client

4. **Interface Segregation**:
   - Các phương thức được nhóm theo loại dữ liệu, giúp client chỉ phụ thuộc vào các phương thức cần thiết
   - Các DAO cung cấp các phương thức cụ thể cho từng loại dữ liệu

5. **Dependency Inversion**:
   - Client phụ thuộc vào abstraction (interface) thay vì implementation cụ thể
   - Sử dụng Riverpod để quản lý dependency injection

6. **DRY**:
   - Tránh lặp lại code bằng cách sử dụng các hằng số và phương thức chung
   - Sử dụng các DAO để tránh lặp lại code truy cập dữ liệu
