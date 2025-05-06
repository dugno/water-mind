# Key-Value Storage trong Water Mind

Ứng dụng Water Mind sử dụng SharedPreferences để lưu trữ các dữ liệu đơn giản, cài đặt và trạng thái ứng dụng. Lớp `KVStoreService` cung cấp một giao diện thống nhất để truy cập và quản lý các dữ liệu này.

## Cấu trúc

```
lib/src/core/services/kv_store/
├── kv_store.dart         # Service chính cho SharedPreferences
└── README.md             # Tài liệu hướng dẫn
```

## Dữ liệu được lưu trữ

### 1. Trạng thái ứng dụng
- **doneGettingStarted**: Đã hoàn thành màn hình giới thiệu hay chưa

### 2. Thông tin người dùng
- **userData**: Dữ liệu người dùng (JSON string)
  - Giới tính
  - Chiều cao
  - Cân nặng
  - Đơn vị đo lường
  - Ngày sinh
  - Mức độ hoạt động
  - Môi trường sống
  - Thời gian thức dậy
  - Thời gian đi ngủ

### 3. Cài đặt giao diện
- **themeStyle**: Kiểu giao diện (index)

### 4. Cache dữ liệu thời tiết
- **weatherCache**: Dữ liệu thời tiết (JSON string)
- **lastWeatherUpdate**: Thời gian cập nhật thời tiết gần nhất

### 5. Cài đặt nhắc nhở
- **waterReminderSettings**: Cài đặt nhắc nhở uống nước (JSON string)
  - Trạng thái bật/tắt
  - Chế độ nhắc nhở
  - Thời gian thức dậy
  - Thời gian đi ngủ
  - Khoảng thời gian nhắc nhở
  - Thời gian nhắc nhở tùy chỉnh
  - Cài đặt bỏ qua nếu đã đạt mục tiêu
  - Cài đặt không làm phiền

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

### Thông tin người dùng

```dart
// Lấy dữ liệu người dùng
final userDataJson = KVStoreService.userDataJson;
final userData = userDataJson != null 
    ? UserOnboardingModel.fromJson(json.decode(userDataJson))
    : null;

// Lưu dữ liệu người dùng
final jsonData = json.encode(userData.toJson());
await KVStoreService.setUserDataJson(jsonData);

// Xóa dữ liệu người dùng
await KVStoreService.clearUserData();
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

### Cài đặt nhắc nhở

```dart
// Lấy cài đặt nhắc nhở
final reminderJson = KVStoreService.waterReminderSettingsJson;
final reminderSettings = reminderJson != null 
    ? WaterReminderSettings.fromJson(json.decode(reminderJson))
    : null;

// Lưu cài đặt nhắc nhở
final jsonData = json.encode(reminderSettings.toJson());
await KVStoreService.setWaterReminderSettingsJson(jsonData);

// Xóa cài đặt nhắc nhở
await KVStoreService.clearWaterReminderSettings();
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

Thiết kế KVStoreService tuân thủ các nguyên tắc SOLID và DRY:

1. **Single Responsibility**: Lớp chỉ chịu trách nhiệm cho việc lưu trữ và truy xuất dữ liệu từ SharedPreferences
2. **Open/Closed**: Có thể mở rộng thêm các phương thức mới mà không cần sửa đổi các phương thức hiện có
3. **Interface Segregation**: Các phương thức được nhóm theo loại dữ liệu, giúp client chỉ phụ thuộc vào các phương thức cần thiết
4. **DRY**: Tránh lặp lại code bằng cách sử dụng các hằng số và phương thức chung
