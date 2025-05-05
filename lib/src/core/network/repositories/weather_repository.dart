import 'package:water_mind/src/core/network/dio_client.dart';
import 'package:water_mind/src/core/network/models/network_result.dart';
import 'package:water_mind/src/core/network/repositories/base_repository.dart';
import 'package:water_mind/src/core/services/weather/models/weather_data.dart';

/// Interface for weather repository
abstract class WeatherRepository {
  /// Get current weather data
  Future<NetworkResult<WeatherData>> getCurrentWeather({
    required double latitude,
    required double longitude,
  });
  
  /// Get weather forecast
  Future<NetworkResult<List<WeatherData>>> getWeatherForecast({
    required double latitude,
    required double longitude,
    required int days,
  });
}

/// Implementation of WeatherRepository
class WeatherRepositoryImpl extends BaseRepositoryImpl implements WeatherRepository {
  /// Constructor for WeatherRepositoryImpl
  WeatherRepositoryImpl(DioClient dioClient) : super(dioClient);

  @override
  Future<NetworkResult<WeatherData>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) {
    return get<WeatherData>(
      path: '/weather/current',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
      },
      fromJson: (data) => WeatherData.fromJson(data),
    );
  }

  @override
  Future<NetworkResult<List<WeatherData>>> getWeatherForecast({
    required double latitude,
    required double longitude,
    required int days,
  }) {
    return get<List<WeatherData>>(
      path: '/weather/forecast',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'days': days,
      },
      fromJson: (data) => (data as List)
          .map((item) => WeatherData.fromJson(item))
          .toList(),
    );
  }
}
