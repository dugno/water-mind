import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';

/// Service for fetching weather data
class WeatherService {
  /// Base URL for the weather API
  final String baseUrl = 'https://api.weatherapi.com/v1';
  
  /// API key for the weather API
  final String apiKey;
  
  /// Constructor
  WeatherService({required this.apiKey});
  
  /// Get the current weather condition for a location
  Future<WeatherCondition> getCurrentWeather(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/current.json?key=$apiKey&q=$location&aqi=no'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int weatherCode = data['current']['condition']['code'];
        
        // Find the matching weather condition
        return WeatherCondition.fromCode(weatherCode);
      } else {
        // Default to cloudy if there's an error
        return WeatherCondition.cloudy;
      }
    } catch (e) {
      // Default to cloudy if there's an exception
      return WeatherCondition.cloudy;
    }
  }
  
  /// Get the forecast for a location
  Future<List<WeatherCondition>> getForecast(String location, {int days = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$location&days=$days&aqi=no'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecastList = data['forecast']['forecastday'] as List;
        
        return forecastList.map<WeatherCondition>((forecast) {
          final int weatherCode = forecast['day']['condition']['code'];
          return WeatherCondition.fromCode(weatherCode);
        }).toList();
      } else {
        // Return a list with cloudy weather if there's an error
        return List.filled(days, WeatherCondition.cloudy);
      }
    } catch (e) {
      // Return a list with cloudy weather if there's an exception
      return List.filled(days, WeatherCondition.cloudy);
    }
  }
}
