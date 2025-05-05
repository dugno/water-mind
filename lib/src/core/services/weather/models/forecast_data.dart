import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';
part 'forecast_data.freezed.dart';
part 'forecast_data.g.dart';

/// Determines if the given time is during daylight hours (5:00 - 17:59)
bool _isDayTime(DateTime dateTime) {
  final hour = dateTime.hour;
  return hour >= 5 && hour < 18;
}

/// Ensures the icon URL is for daytime conditions
String _getDayIcon(String iconUrl) {
  // Make sure the URL is complete
  String completeUrl = iconUrl.startsWith('//') ? 'https:$iconUrl' : iconUrl;

  // Make sure the icon is for daytime
  if (completeUrl.contains('night')) {
    completeUrl = completeUrl.replaceAll('night', 'day');
  }

  return completeUrl;
}

/// Helper function to transform current weather JSON to match WeatherData model
Map<String, dynamic> _transformCurrentJson(Map<String, dynamic> current, Map<String, dynamic> location) {
  // Get the numeric weather code
  final int weatherCode = current['condition']['code'];

  // Convert the numeric code to the corresponding enum value using fromCode method
  final weatherCondition = WeatherCondition.fromCode(weatherCode);

  // Get the string representation of the enum value for JSON serialization
  final weatherConditionString = weatherCondition.name;

  return {
    'temperature': current['temp_c'],
    'feelsLike': current['feelslike_c'],
    'humidity': current['humidity'],
    'windSpeed': current['wind_kph'],
    'condition': weatherConditionString, // Use the string representation of the enum
    'description': current['condition']['text'],
    'iconUrl': current['condition']['icon'].startsWith('//')
        ? 'https:${current['condition']['icon']}'
        : current['condition']['icon'],
    'timestamp': DateTime.parse(current['last_updated']).toIso8601String(),
    'cityName': location['name'],
    'countryCode': location['country'],
    'isDay': current.containsKey('is_day')
        ? current['is_day'] == 1
        : _isDayTime(DateTime.parse(current['last_updated'])), // Determine based on time if not specified
  };
}

/// Model for weather forecast data
@freezed
class ForecastData with _$ForecastData {
  /// Default constructor for ForecastData
  const factory ForecastData({
    /// Current weather data
    required WeatherData current,

    /// Forecast for upcoming days
    required List<DailyForecast> forecast,

    /// Location information
    required LocationData location,

    /// Timestamp when this data was fetched
    required DateTime lastUpdated,
  }) = _ForecastData;

  /// Factory constructor for creating a ForecastData from JSON
  factory ForecastData.fromJson(Map<String, dynamic> json) => _$ForecastDataFromJson(json);

  /// Custom fromJson implementation for WeatherAPI.com format
  static ForecastData fromWeatherApi(Map<String, dynamic> json) {
    // Note: We don't need to determine isDay here as it's already handled in _transformCurrentJson

    // Transform current weather data
    final current = WeatherData.fromJson(_transformCurrentJson(json['current'], json['location']));

    // Handle the case where forecast data might not be present in the response
    final List<DailyForecast> forecastDays = [];
    if (json.containsKey('forecast') && json['forecast'] is Map && json['forecast'].containsKey('forecastday')) {
      forecastDays.addAll((json['forecast']['forecastday'] as List)
          .map((day) => DailyForecast.fromWeatherApi(day))
          .toList());
    }

    final location = LocationData.fromWeatherApi(json['location']);

    // Create a ForecastData object with the current timestamp
    // Convert DateTime.now() to ISO 8601 string and then parse it back to ensure proper serialization
    final now = DateTime.now();
    return ForecastData(
      current: current,
      forecast: forecastDays,
      location: location,
      lastUpdated: DateTime.parse(now.toIso8601String()),
    );
  }
}

/// Model for daily forecast data
@freezed
class DailyForecast with _$DailyForecast {
  /// Default constructor for DailyForecast
  const factory DailyForecast({
    /// Date of the forecast
    required DateTime date,

    /// Maximum temperature in Celsius
    required double maxTemp,

    /// Minimum temperature in Celsius
    required double minTemp,

    /// Average temperature in Celsius
    required double avgTemp,

    /// Maximum wind speed in km/h
    required double maxWind,

    /// Total precipitation in mm
    required double totalPrecip,

    /// Average humidity
    required double avgHumidity,

    /// Weather condition
    required int conditionCode,

    /// Weather condition text
    required String conditionText,

    /// Weather condition icon URL
    required String conditionIcon,

    /// Hourly forecast data
    required List<HourlyForecast> hourly,
  }) = _DailyForecast;

  /// Factory constructor for creating a DailyForecast from JSON
  factory DailyForecast.fromJson(Map<String, dynamic> json) => _$DailyForecastFromJson(json);

  /// Custom fromJson implementation for WeatherAPI.com format
  static DailyForecast fromWeatherApi(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>;
    final List<HourlyForecast> hourlyData = [];

    if (json.containsKey('hour') && json['hour'] is List) {
      hourlyData.addAll((json['hour'] as List)
          .map((hour) {
            // Determine if it's day time based on the hour
            final hourTime = DateTime.parse(hour['time'] as String);
            final isDay = _isDayTime(hourTime);

            return HourlyForecast.fromWeatherApi(
              hour as Map<String, dynamic>,
              isDay: isDay,
            );
          })
          .toList());
    }

    // Parse the forecast date
    final forecastDate = DateTime.parse(json['date'] as String);

    // Get the weather condition code and convert it to the enum
    final int conditionCode = day['condition']['code'] as int;

    return DailyForecast(
      date: forecastDate,
      maxTemp: (day['maxtemp_c'] as num).toDouble(),
      minTemp: (day['mintemp_c'] as num).toDouble(),
      avgTemp: (day['avgtemp_c'] as num).toDouble(),
      maxWind: (day['maxwind_kph'] as num).toDouble(),
      totalPrecip: (day['totalprecip_mm'] as num).toDouble(),
      avgHumidity: (day['avghumidity'] as num).toDouble(),
      conditionCode: conditionCode,
      conditionText: day['condition']['text'] as String,
      conditionIcon: _getDayIcon(day['condition']['icon'] as String),
      hourly: hourlyData,
    );
  }
}

/// Model for hourly forecast data
@freezed
class HourlyForecast with _$HourlyForecast {
  /// Default constructor for HourlyForecast
  const factory HourlyForecast({
    /// Time of the forecast
    required DateTime time,

    /// Temperature in Celsius
    required double temp,

    /// Feels like temperature in Celsius
    required double feelsLike,

    /// Wind speed in km/h
    required double windSpeed,

    /// Wind direction
    required String windDir,

    /// Pressure in millibars
    required double pressure,

    /// Precipitation in mm
    required double precip,

    /// Humidity percentage
    required int humidity,

    /// Cloud cover percentage
    required int cloud,

    /// Weather condition code
    required int conditionCode,

    /// Weather condition text
    required String conditionText,

    /// Weather condition icon URL
    required String conditionIcon,
  }) = _HourlyForecast;

  /// Factory constructor for creating an HourlyForecast from JSON
  factory HourlyForecast.fromJson(Map<String, dynamic> json) => _$HourlyForecastFromJson(json);

  /// Custom fromJson implementation for WeatherAPI.com format
  static HourlyForecast fromWeatherApi(Map<String, dynamic> json, {bool? isDay}) {
    // If isDay is not provided, determine it based on the time
    final hourTime = DateTime.parse(json['time']);
    final isDayTime = isDay ?? _isDayTime(hourTime);

    // Check if is_day is provided in the JSON
    final hasIsDay = json.containsKey('is_day');
    final jsonIsDay = hasIsDay ? json['is_day'] == 1 : isDayTime;

    // Get the appropriate icon based on whether it's day or night
    String iconUrl = json['condition']['icon'] as String;
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    }

    // If the icon URL contains "day" or "night", make sure it matches the actual time
    if (!jsonIsDay && iconUrl.contains('day')) {
      // Replace day with night in the icon URL
      iconUrl = iconUrl.replaceAll('day', 'night');
    } else if (jsonIsDay && iconUrl.contains('night')) {
      // Replace night with day in the icon URL
      iconUrl = iconUrl.replaceAll('night', 'day');
    }

    // Get the weather condition code
    final int conditionCode = json['condition']['code'] as int;

    return HourlyForecast(
      time: hourTime,
      temp: (json['temp_c'] as num).toDouble(),
      feelsLike: (json['feelslike_c'] as num).toDouble(),
      windSpeed: (json['wind_kph'] as num).toDouble(),
      windDir: json['wind_dir'] as String,
      pressure: (json['pressure_mb'] as num).toDouble(),
      precip: (json['precip_mm'] as num).toDouble(),
      humidity: json['humidity'] as int,
      cloud: json['cloud'] as int,
      conditionCode: conditionCode,
      conditionText: json['condition']['text'] as String,
      conditionIcon: iconUrl,
    );
  }
}

/// Model for location data
@freezed
class LocationData with _$LocationData {
  /// Default constructor for LocationData
  const factory LocationData({
    /// Name of the location
    required String name,

    /// Region of the location
    required String region,

    /// Country of the location
    required String country,

    /// Latitude of the location
    required double lat,

    /// Longitude of the location
    required double lon,

    /// Timezone ID
    required String tzId,

    /// Local time
    required String localtime,
  }) = _LocationData;

  /// Factory constructor for creating a LocationData from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);

  /// Custom fromJson implementation for WeatherAPI.com format
  static LocationData fromWeatherApi(Map<String, dynamic> json) {
    return LocationData(
      name: json['name'] as String,
      region: json['region'] as String,
      country: json['country'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      tzId: json['tz_id'] as String,
      localtime: json['localtime'] as String,
    );
  }
}
