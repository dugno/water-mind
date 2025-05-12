# Tính năng mới trong Water Mind

## 1. Lưu lại lựa chọn loại đồ uống và lượng nước uống gần nhất

### Mô tả
Tính năng này cho phép ứng dụng lưu trữ và sử dụng lại loại đồ uống và lượng nước mà người dùng đã chọn gần nhất. Điều này giúp cải thiện trải nghiệm người dùng bằng cách tự động điền các giá trị mặc định dựa trên thói quen uống nước gần đây của họ.

### Cấu trúc dữ liệu
- **Bảng UserPreferencesTable**: Lưu trữ tùy chọn người dùng, bao gồm loại đồ uống và lượng nước gần nhất.
- **Model UserPreferencesModel**: Đại diện cho dữ liệu tùy chọn người dùng.
- **DAO UserPreferencesDao**: Cung cấp các phương thức truy cập dữ liệu.
- **Repository UserPreferencesRepository**: Trừu tượng hóa truy cập dữ liệu.
- **Provider userPreferencesProvider**: Cung cấp trạng thái tùy chọn người dùng.

### Cách sử dụng

#### Lấy thông tin loại đồ uống và lượng nước gần nhất
```dart
// Trong một widget
final userPreferencesAsync = ref.watch(userPreferencesProvider);

return userPreferencesAsync.when(
  data: (preferences) {
    // Lấy loại nước gần nhất
    final lastDrinkType = ref.watch(lastDrinkTypeProvider(preferences));
    
    // Lấy lượng nước gần nhất
    final lastDrinkAmount = ref.watch(lastDrinkAmountProvider(preferences));
    
    // Sử dụng các giá trị này làm mặc định
    return YourWidget(
      defaultDrinkType: lastDrinkType,
      defaultAmount: lastDrinkAmount,
    );
  },
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text('Error: $error'),
);
```

#### Cập nhật thông tin loại đồ uống và lượng nước gần nhất
```dart
// Khi người dùng thêm một lần uống nước mới
Future<void> addWaterIntake(DrinkType drinkType, double amount) async {
  // Thêm vào lịch sử uống nước
  final waterIntakeRepository = ref.read(waterIntakeRepositoryProvider);
  final entry = WaterIntakeEntry(
    id: generateUuid(),
    timestamp: DateTime.now(),
    amount: amount,
    drinkType: drinkType,
  );
  
  await waterIntakeRepository.addWaterIntakeEntry(DateTime.now(), entry);
  
  // Cập nhật thông tin uống nước gần nhất
  final userPreferencesRepository = ref.read(userPreferencesRepositoryProvider);
  await userPreferencesRepository.updateLastDrinkInfo(drinkType.id, amount);
}
```

## 2. Tính lượng nước khuyến nghị cho 3 ngày tiếp theo dựa vào dự báo thời tiết

### Mô tả
Tính năng này cho phép ứng dụng tính toán và hiển thị lượng nước khuyến nghị cho 3 ngày tiếp theo dựa trên dự báo thời tiết. Dữ liệu dự báo được lưu trữ trong cơ sở dữ liệu để sử dụng ngay cả khi không có kết nối internet.

### Cấu trúc dữ liệu
- **Bảng ForecastHydrationTable**: Lưu trữ dự báo lượng nước cho các ngày tiếp theo.
- **Model ForecastHydrationModel**: Đại diện cho dữ liệu dự báo lượng nước.
- **DAO ForecastHydrationDao**: Cung cấp các phương thức truy cập dữ liệu.
- **Repository ForecastHydrationRepository**: Trừu tượng hóa truy cập dữ liệu.
- **Service ForecastHydrationService**: Xử lý logic tính toán lượng nước khuyến nghị.
- **Provider forecastHydrationProvider**: Cung cấp dự báo lượng nước.

### Cách sử dụng

#### Lấy dự báo lượng nước
```dart
// Trong một widget
final forecastAsync = ref.watch(forecastHydrationProvider(3)); // 3 ngày

return forecastAsync.when(
  data: (forecast) {
    // Hiển thị dự báo
    return ListView.builder(
      itemCount: forecast.length,
      itemBuilder: (context, index) {
        final item = forecast[index];
        return ListTile(
          title: Text(item.date.toString()),
          subtitle: Text(item.weatherDescription),
          trailing: Text(item.getFormattedWaterIntake()),
        );
      },
    );
  },
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text('Error: $error'),
);
```

#### Làm mới dự báo lượng nước
```dart
// Khi người dùng muốn làm mới dự báo
void refreshForecast() {
  // Tính toán lại dự báo
  ref.refresh(calculateForecastHydrationProvider(3));
}
```

## Cách chạy build_runner để tạo các lớp tự động

Sau khi thêm các bảng mới vào cơ sở dữ liệu, bạn cần chạy build_runner để tạo các lớp tự động:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Hoặc để theo dõi các thay đổi và tự động tạo lại:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Lưu ý quan trọng

1. **Migration**: Khi cập nhật schema cơ sở dữ liệu, đảm bảo rằng bạn đã cập nhật phiên bản cơ sở dữ liệu và thêm migration để nâng cấp từ phiên bản cũ.

2. **Freezed Models**: Sau khi tạo các model mới, bạn cần chạy build_runner để tạo các lớp freezed.

3. **Riverpod Providers**: Đảm bảo rằng bạn đã đăng ký các provider mới trong ứng dụng.

4. **Localization**: Đảm bảo rằng bạn đã thêm các chuỗi localization mới vào các file arb.

5. **Testing**: Viết các test để đảm bảo rằng các tính năng mới hoạt động đúng.
