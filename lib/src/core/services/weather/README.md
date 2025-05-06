# Weather Service trong Water Mind

Ứng dụng Water Mind sử dụng `DailyWeatherService` để quản lý việc gọi API thời tiết một cách hiệu quả, chỉ gọi một lần duy nhất trong ngày và reset cache vào 00h00 mỗi ngày.

## Cấu trúc

```
lib/src/core/services/weather/
├── daily_weather_service.dart    # Service chính cho việc gọi API thời tiết hàng ngày
├── models/                       # Các model cho dữ liệu thời tiết
│   ├── forecast_data.dart        # Model cho dữ liệu dự báo
│   └── weather_data.dart         # Model cho dữ liệu thời tiết hiện tại
├── weather_cache_manager.dart    # Manager cho việc cache dữ liệu thời tiết
└── README.md                     # Tài liệu hướng dẫn
```

## Cách hoạt động

### 1. Gọi API một lần duy nhất trong ngày

`DailyWeatherService` sẽ kiểm tra xem đã gọi API thời tiết trong ngày hôm nay chưa bằng cách so sánh ngày của lần gọi API gần nhất (lưu trong SharedPreferences) với ngày hiện tại:

```dart
bool _shouldFetchWeatherToday() {
  final lastUpdateTimestamp = KVStoreService.lastWeatherUpdate;
  if (lastUpdateTimestamp == 0) return true;

  final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateTimestamp);
  final now = DateTime.now();
  
  // Check if the last update was on a different day
  return lastUpdate.year != now.year || 
         lastUpdate.month != now.month || 
         lastUpdate.day != now.day;
}
```

### 2. Reset cache vào 00h00 mỗi ngày

`DailyWeatherService` sẽ tự động lên lịch một timer để reset cache vào 00h00 mỗi ngày:

```dart
void _scheduleMidnightReset() {
  // Cancel any existing timer
  _midnightTimer?.cancel();

  // Calculate time until next midnight
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final timeUntilMidnight = tomorrow.difference(now);

  // Schedule the timer
  _midnightTimer = Timer(timeUntilMidnight, () {
    _resetCacheAndFetchWeather();
    // Reschedule for the next day
    _scheduleMidnightReset();
  });
}
```

## Cách sử dụng

### Khởi tạo

`DailyWeatherService` được khởi tạo tự động thông qua Riverpod provider:

```dart
final service = ref.watch(dailyWeatherServiceProvider);
```

### Lấy dữ liệu thời tiết hiện tại

```dart
// Trong một widget
final weatherAsync = ref.watch(dailyCurrentWeatherProvider(forceRefresh: false));

// Trong một provider hoặc service
final weatherResult = await ref.read(dailyCurrentWeatherProvider(forceRefresh: false).future);
```

### Lấy dữ liệu dự báo thời tiết

```dart
// Trong một widget
final forecastAsync = ref.watch(dailyWeatherForecastProvider(days: 3, forceRefresh: false));

// Trong một provider hoặc service
final forecastResult = await ref.read(dailyWeatherForecastProvider(days: 3, forceRefresh: false).future);
```

### Lấy cả dữ liệu hiện tại và dự báo

```dart
// Trong một widget
final weatherAndForecastAsync = ref.watch(dailyWeatherAndForecastProvider(forceRefresh: false));

// Trong một provider hoặc service
final weatherAndForecastResult = await ref.read(dailyWeatherAndForecastProvider(forceRefresh: false).future);
```

## Lợi ích

1. **Tiết kiệm API calls**: Chỉ gọi API một lần duy nhất trong ngày, giúp tiết kiệm quota API và tránh bị rate limit.
2. **Tự động cập nhật**: Tự động reset cache và cập nhật dữ liệu thời tiết vào 00h00 mỗi ngày.
3. **Hiệu suất tốt**: Sử dụng cache để trả về dữ liệu ngay lập tức mà không cần chờ API.
4. **Dễ sử dụng**: Cung cấp các Riverpod provider đơn giản để truy cập dữ liệu.

## Nguyên tắc thiết kế

Thiết kế `DailyWeatherService` tuân thủ các nguyên tắc SOLID và DRY:

1. **Single Responsibility**: Service chỉ chịu trách nhiệm cho việc quản lý gọi API thời tiết.
2. **Open/Closed**: Có thể mở rộng thêm các tính năng mới mà không cần sửa đổi code hiện có.
3. **Liskov Substitution**: Các provider có thể thay thế lẫn nhau vì chúng đều trả về cùng một kiểu dữ liệu.
4. **Interface Segregation**: Cung cấp các provider riêng biệt cho từng loại dữ liệu.
5. **Dependency Inversion**: Sử dụng Riverpod để quản lý dependency injection.
6. **DRY**: Tránh lặp lại code bằng cách tái sử dụng logic chung.
