# Weather Icon Mapper

Lớp `WeatherIconMapper` cung cấp một cách để ánh xạ các mã điều kiện thời tiết từ WeatherAPI.com với các hình ảnh SVG trong thư mục assets của ứng dụng.

## Xác định thời gian ban ngày/đêm

Ứng dụng xác định thời gian ban ngày/đêm dựa trên các quy tắc sau:

1. Nếu API trả về trường `is_day` (1 cho ban ngày, 0 cho ban đêm), sử dụng giá trị này
2. Nếu không có trường `is_day`, xác định dựa trên giờ hiện tại:
   - Ban ngày: 5:00 - 17:59
   - Ban đêm: 18:00 - 4:59
3. Dự báo theo ngày luôn sử dụng icon ban ngày

## Cách sử dụng

```dart
import 'package:water_mind/src/core/utils/weather/weather_icon_mapper.dart';

// Lấy icon thời tiết dựa trên mã điều kiện thời tiết
final weatherIcon = WeatherIconMapper.getWeatherIcon(
  1000, // Mã điều kiện thời tiết từ WeatherAPI.com
  isDay: true, // true cho ban ngày, false cho ban đêm
);

// Sử dụng icon trong widget
SizedBox(
  width: 64,
  height: 64,
  child: weatherIcon.svg(
    fit: BoxFit.contain,
  ),
)
```

## Danh sách mã điều kiện thời tiết

WeatherAPI.com cung cấp các mã điều kiện thời tiết sau:

| Mã | Điều kiện (Ban ngày) | Điều kiện (Ban đêm) |
|----|----------------------|---------------------|
| 1000 | Sunny | Clear |
| 1003 | Partly cloudy | Partly cloudy |
| 1006 | Cloudy | Cloudy |
| 1009 | Overcast | Overcast |
| 1030 | Mist | Mist |
| 1063 | Patchy rain possible | Patchy rain possible |
| 1066 | Patchy snow possible | Patchy snow possible |
| 1069 | Patchy sleet possible | Patchy sleet possible |
| 1072 | Patchy freezing drizzle possible | Patchy freezing drizzle possible |
| 1087 | Thundery outbreaks possible | Thundery outbreaks possible |
| 1114 | Blowing snow | Blowing snow |
| 1117 | Blizzard | Blizzard |
| 1135 | Fog | Fog |
| 1147 | Freezing fog | Freezing fog |
| 1150 | Patchy light drizzle | Patchy light drizzle |
| 1153 | Light drizzle | Light drizzle |
| 1168 | Freezing drizzle | Freezing drizzle |
| 1171 | Heavy freezing drizzle | Heavy freezing drizzle |
| 1180 | Patchy light rain | Patchy light rain |
| 1183 | Light rain | Light rain |
| 1186 | Moderate rain at times | Moderate rain at times |
| 1189 | Moderate rain | Moderate rain |
| 1192 | Heavy rain at times | Heavy rain at times |
| 1195 | Heavy rain | Heavy rain |
| 1198 | Light freezing rain | Light freezing rain |
| 1201 | Moderate or heavy freezing rain | Moderate or heavy freezing rain |
| 1204 | Light sleet | Light sleet |
| 1207 | Moderate or heavy sleet | Moderate or heavy sleet |
| 1210 | Patchy light snow | Patchy light snow |
| 1213 | Light snow | Light snow |
| 1216 | Patchy moderate snow | Patchy moderate snow |
| 1219 | Moderate snow | Moderate snow |
| 1222 | Patchy heavy snow | Patchy heavy snow |
| 1225 | Heavy snow | Heavy snow |
| 1237 | Ice pellets | Ice pellets |
| 1240 | Light rain shower | Light rain shower |
| 1243 | Moderate or heavy rain shower | Moderate or heavy rain shower |
| 1246 | Torrential rain shower | Torrential rain shower |
| 1249 | Light sleet showers | Light sleet showers |
| 1252 | Moderate or heavy sleet showers | Moderate or heavy sleet showers |
| 1255 | Light snow showers | Light snow showers |
| 1258 | Moderate or heavy snow showers | Moderate or heavy snow showers |
| 1261 | Light showers of ice pellets | Light showers of ice pellets |
| 1264 | Moderate or heavy showers of ice pellets | Moderate or heavy showers of ice pellets |
| 1273 | Patchy light rain with thunder | Patchy light rain with thunder |
| 1276 | Moderate or heavy rain with thunder | Moderate or heavy rain with thunder |
| 1279 | Patchy light snow with thunder | Patchy light snow with thunder |
| 1282 | Moderate or heavy snow with thunder | Moderate or heavy snow with thunder |

## Cách hoạt động

1. `WeatherIconMapper` nhận mã điều kiện thời tiết từ WeatherAPI.com
2. Chuyển đổi mã này thành enum `WeatherCondition` tương ứng
3. Dựa vào `WeatherCondition` và thời gian trong ngày (ngày/đêm), trả về hình ảnh SVG tương ứng từ thư mục assets

## Tùy chỉnh

Nếu bạn muốn thêm hoặc thay đổi các hình ảnh thời tiết, hãy:

1. Thêm hình ảnh SVG mới vào thư mục `assets/images/weather/`
2. Chạy lại flutter_gen để cập nhật file `assets.gen.dart`
3. Cập nhật phương thức `_getIconForCondition` trong `WeatherIconMapper` để sử dụng hình ảnh mới
