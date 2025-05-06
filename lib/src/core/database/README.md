# Local Storage trong Water Mind

Ứng dụng Water Mind sử dụng hai cơ chế lưu trữ dữ liệu cục bộ:

1. **SharedPreferences**: Cho dữ liệu đơn giản, cài đặt và trạng thái ứng dụng
2. **Drift (SQLite)**: Cho dữ liệu có cấu trúc phức tạp và cần truy vấn

## Cấu trúc thư mục

```
lib/src/core/
├── database/                  # Drift database
│   ├── daos/                  # Data Access Objects
│   │   └── water_intake_dao.dart
│   ├── database.dart          # Định nghĩa cơ sở dữ liệu
│   ├── database_initializer.dart # Khởi tạo cơ sở dữ liệu
│   └── tables.dart            # Định nghĩa các bảng
├── services/
│   ├── kv_store/              # SharedPreferences
│   │   └── kv_store.dart
│   ├── hydration/
│   │   ├── water_intake_provider.dart # Providers cho water intake
│   │   └── water_intake_repository.dart # Repository cho water intake
```

## Dữ liệu được lưu trữ

### Sử dụng SharedPreferences

1. **Thông tin người dùng (UserRepository)**
   - Giới tính, chiều cao, cân nặng, đơn vị đo lường
   - Ngày sinh, mức độ hoạt động, môi trường sống
   - Thời gian thức dậy, thời gian đi ngủ

2. **Cài đặt nhắc nhở (WaterReminderService)**
   - Trạng thái bật/tắt, chế độ nhắc nhở
   - Thời gian thức dậy, thời gian đi ngủ
   - Khoảng thời gian nhắc nhở, thời gian tùy chỉnh
   - Cài đặt bỏ qua nếu đã đạt mục tiêu, không làm phiền

3. **Cài đặt giao diện (ThemeRepository)**
   - Kiểu giao diện

4. **Cache dữ liệu thời tiết (WeatherCacheManager)**
   - Dữ liệu thời tiết hiện tại và dự báo

5. **Trạng thái hoàn thành màn hình giới thiệu (KVStoreService)**
   - Đã hoàn thành hay chưa

### Sử dụng Drift (SQLite)

1. **Lịch sử uống nước (WaterIntakeRepository)**
   - Bảng `WaterIntakeHistoryTable`: Lưu thông tin lịch sử theo ngày
     - ID, ngày, mục tiêu hàng ngày, đơn vị đo lường
   - Bảng `WaterIntakeEntryTable`: Lưu thông tin từng lần uống nước
     - ID, historyId, thời gian, lượng nước, loại đồ uống, ghi chú

## Cách sử dụng

### Khởi tạo

Cơ sở dữ liệu được khởi tạo trong `main.dart`:

```dart
void main() async {
  // ...
  await KVStoreService.init();
  await DatabaseInitializer.initialize();
  // ...
}
```

### Sử dụng Repository

Các repository được cung cấp thông qua Riverpod providers:

```dart
// Lấy repository
final repository = ref.watch(waterIntakeRepositoryProvider);

// Lấy lịch sử uống nước theo ngày
final history = await repository.getWaterIntakeHistory(date);

// Lưu lịch sử uống nước
await repository.saveWaterIntakeHistory(history);

// Thêm một lần uống nước mới
await repository.addWaterIntakeEntry(date, entry);

// Xóa một lần uống nước
await repository.deleteWaterIntakeEntry(date, entryId);
```

### Sử dụng Providers

Các providers được cung cấp để truy cập dữ liệu một cách reactive:

```dart
// Lấy lịch sử uống nước theo ngày
final historyAsync = ref.watch(waterIntakeHistoryProvider(date));

// Lấy tất cả lịch sử uống nước
final allHistoryAsync = ref.watch(allWaterIntakeHistoryProvider);
```

## Nguyên tắc thiết kế

Thiết kế local storage tuân thủ các nguyên tắc SOLID và DRY:

1. **Single Responsibility**: Mỗi repository chỉ chịu trách nhiệm cho một loại dữ liệu
2. **Open/Closed**: Các interface mở rộng nhưng không sửa đổi
3. **Liskov Substitution**: Các implementation có thể thay thế interface
4. **Interface Segregation**: Client chỉ phụ thuộc vào các phương thức cần thiết
5. **Dependency Inversion**: Module cấp cao phụ thuộc vào abstraction, không phụ thuộc vào implementation

## Code Generation

Để tạo các file cần thiết cho Drift, chạy lệnh:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
