import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

/// Model for weather data
@freezed
class WeatherData with _$WeatherData {
  /// Default constructor for WeatherData
  const factory WeatherData({
    required double temperature,
    required double feelsLike,
    required int humidity,
    required double windSpeed,
    required WeatherCondition condition,
    required String description,
    required String iconUrl,
    required DateTime timestamp,
    String? cityName,
    String? countryCode,
    @Default(true) bool isDay,
  }) = _WeatherData;

  /// Factory constructor for creating a WeatherData from JSON
  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
}
