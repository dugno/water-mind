import 'package:water_mind/gen/assets.gen.dart';
import 'package:water_mind/src/core/utils/enum/weather_condition.dart';

/// A utility class to map weather condition codes to appropriate weather icons
class WeatherIconMapper {
  /// Get the appropriate SVG image for a weather condition code
  /// 
  /// [conditionCode] - The weather condition code from WeatherAPI.com
  /// [isDay] - Whether it's daytime (true) or nighttime (false)
  static SvgGenImage getWeatherIcon(int conditionCode, {bool isDay = true}) {
    // Get the weather condition from the code
    final weatherCondition = WeatherCondition.fromCode(conditionCode);
    
    // Get the appropriate icon based on the weather condition and time of day
    return _getIconForCondition(weatherCondition, isDay: isDay);
  }
  
  /// Get the appropriate SVG image for a weather condition
  /// 
  /// [condition] - The WeatherCondition enum value
  /// [isDay] - Whether it's daytime (true) or nighttime (false)
  static SvgGenImage getWeatherIconFromCondition(WeatherCondition condition, {bool isDay = true}) {
    return _getIconForCondition(condition, isDay: isDay);
  }
  
  /// Internal method to map weather conditions to appropriate icons
  static SvgGenImage _getIconForCondition(WeatherCondition condition, {bool isDay = true}) {
    final weather = Assets.images.weather;
    
    switch (condition) {
      // Sunny / Clear
      case WeatherCondition.sunny:
        return isDay ? weather.sunny : weather.clearNight;
      
      // Partly Cloudy
      case WeatherCondition.partlyCloudy:
        return isDay ? weather.partlyCloudy : weather.partlyCloudyNight;
      
      // Cloudy
      case WeatherCondition.cloudy:
        return isDay ? weather.cloudy : weather.cloudyNight;
      
      // Overcast
      case WeatherCondition.overcast:
        return isDay ? weather.overcast : weather.overcastNight;
      
      // Mist
      case WeatherCondition.mist:
        return isDay ? weather.mist : weather.mistNight;
      
      // Patchy rain possible
      case WeatherCondition.patchyRainPossible:
        return isDay ? weather.patchyRain : weather.patchyRainNight;
      
      // Patchy snow possible
      case WeatherCondition.patchySnowPossible:
        return isDay ? weather.patchySnow : weather.patchySnowNight;
      
      // Patchy sleet possible
      case WeatherCondition.patchySleetPossible:
        return isDay ? weather.patchySleet : weather.patchySleetNight;
      
      // Patchy freezing drizzle possible
      case WeatherCondition.patchyFreezingDrizzlePossible:
        return isDay ? weather.patchyFreezingDrizzle : weather.patchyFreezingDrizzleNight;
      
      // Thundery outbreaks possible
      case WeatherCondition.thunderyOutbreaksPossible:
        return isDay ? weather.thunderyOutbreaks : weather.thunderyOutbreaksNight;
      
      // Blowing snow
      case WeatherCondition.blowingSnow:
        return isDay ? weather.blowingSnow : weather.blowingSnowNight;
      
      // Blizzard
      case WeatherCondition.blizzard:
        return isDay ? weather.blizzard : weather.blizzardNight;
      
      // Fog
      case WeatherCondition.fog:
        return isDay ? weather.fog : weather.fogNight;
      
      // Freezing fog
      case WeatherCondition.freezingFog:
        return isDay ? weather.freezingFog : weather.freezingFogNight;
      
      // Patchy light drizzle
      case WeatherCondition.patchyLightDrizzle:
        return isDay ? weather.patchyLightDrizzle : weather.patchyLightDrizzleNight;
      
      // Light drizzle
      case WeatherCondition.lightDrizzle:
        return isDay ? weather.lightDrizzle : weather.lightDrizzleNight;
      
      // Freezing drizzle
      case WeatherCondition.freezingDrizzle:
        return isDay ? weather.freezingDrizzle : weather.freezingDrizzleNight;
      
      // Heavy freezing drizzle
      case WeatherCondition.heavyFreezingDrizzle:
        return isDay ? weather.heavyFreezingDrizzle : weather.heavyFreezingDrizzleNight;
      
      // Patchy light rain
      case WeatherCondition.patchyLightRain:
        return isDay ? weather.patchyLightRain : weather.patchyLightRainNight;
      
      // Light rain
      case WeatherCondition.lightRain:
        return isDay ? weather.lightRain : weather.lightRainNight;
      
      // Moderate rain at times
      case WeatherCondition.moderateRainAtTimes:
        return isDay ? weather.moderateRainAtTimes : weather.moderateRainAtTimesNight;
      
      // Moderate rain
      case WeatherCondition.moderateRain:
        return isDay ? weather.moderateRain : weather.moderateRainNight;
      
      // Heavy rain at times
      case WeatherCondition.heavyRainAtTimes:
        return isDay ? weather.heavyRainAtTimes : weather.heavyRainAtTimesNight;
      
      // Heavy rain
      case WeatherCondition.heavyRain:
        return isDay ? weather.heavyRain : weather.heavyRainNight;
      
      // Light freezing rain
      case WeatherCondition.lightFreezingRain:
        return isDay ? weather.lightFreezingRain : weather.lightFreezingRainNight;
      
      // Moderate or heavy freezing rain
      case WeatherCondition.moderateOrHeavyFreezingRain:
        return isDay ? weather.moderateOrHeavyFreezingRain : weather.moderateOrHeavyFreezingRainNight;
      
      // Light sleet
      case WeatherCondition.lightSleet:
        return isDay ? weather.lightSleet : weather.lightSleetNight;
      
      // Moderate or heavy sleet
      case WeatherCondition.moderateOrHeavySleet:
        return isDay ? weather.moderateOrHeavySleet : weather.moderateOrHeavySleetNight;
      
      // Patchy light snow
      case WeatherCondition.patchyLightSnow:
        return isDay ? weather.patchyLightSnow : weather.patchyLightSnowNight;
      
      // Light snow
      case WeatherCondition.lightSnow:
        return isDay ? weather.lightSnow : weather.lightSnowNight;
      
      // Patchy moderate snow
      case WeatherCondition.patchyModerateSnow:
        return isDay ? weather.patchyModerateSnow : weather.patchyModerateSnowNight;
      
      // Moderate snow
      case WeatherCondition.moderateSnow:
        return isDay ? weather.moderateSnow : weather.moderateSnowNight;
      
      // Patchy heavy snow
      case WeatherCondition.patchyHeavySnow:
        return isDay ? weather.patchyHeavySnow : weather.patchyHeavySnowNight;
      
      // Heavy snow
      case WeatherCondition.heavySnow:
        return isDay ? weather.heavySnow : weather.heavySnowNight;
      
      // Ice pellets
      case WeatherCondition.icePellets:
        return isDay ? weather.icePellets : weather.icePelletsNight;
      
      // Light rain shower
      case WeatherCondition.lightRainShower:
        return isDay ? weather.lightRainShower : weather.lightRainShowerNight;
      
      // Moderate or heavy rain shower
      case WeatherCondition.moderateOrHeavyRainShower:
        return isDay ? weather.moderateOrHeavyRainShower : weather.moderateOrHeavyRainShowerNight;
      
      // Torrential rain shower
      case WeatherCondition.torrentialRainShower:
        return isDay ? weather.torrentialRainShower : weather.torrentialRainShowerNight;
      
      // Light sleet showers
      case WeatherCondition.lightSleetShowers:
        return isDay ? weather.lightSleetShower : weather.lightSleetShowerNight;
      
      // Moderate or heavy sleet showers
      case WeatherCondition.moderateOrHeavySleetShowers:
        return isDay ? weather.moderateOrHeavySleetShowers : weather.moderateOrHeavySleetShowersNight;
      
      // Light snow showers
      case WeatherCondition.lightSnowShowers:
        return isDay ? weather.lightSnowShowers : weather.lightSnowShowersNight;
      
      // Moderate or heavy snow showers
      case WeatherCondition.moderateOrHeavySnowShowers:
        return isDay ? weather.moderateOrHeavySnowShowers : weather.moderateOrHeavySnowShowersNight;
      
      // Light showers of ice pellets
      case WeatherCondition.lightShowersOfIcePellets:
        return isDay ? weather.lightShowersOfIcePellets : weather.lightShowersOfIcePelletsNight;
      
      // Moderate or heavy showers of ice pellets
      case WeatherCondition.moderateOrHeavyShowersOfIcePellets:
        return isDay ? weather.moderateOrHeavyShowersOfIcePellets : weather.moderateOrHeavyShowersOfIcePelletsNight;
      
      // Patchy light rain with thunder
      case WeatherCondition.patchyLightRainWithThunder:
        return isDay ? weather.patchyLightRainWithThunder : weather.patchyLightRainWithThunderNight;
      
      // Moderate or heavy rain with thunder
      case WeatherCondition.moderateOrHeavyRainWithThunder:
        return isDay ? weather.moderateOrHeavyRainWithThunder : weather.moderateOrHeavyRainWithThunderNight;
      
      // Patchy light snow with thunder
      case WeatherCondition.patchyLightSnowWithThunder:
        return isDay ? weather.patchyLightSnowWithThunder : weather.patchyLightSnowWithThunderNight;
      
      // Moderate or heavy snow with thunder
      case WeatherCondition.moderateOrHeavySnowWithThunder:
        return isDay ? weather.moderateOrHeavySnowWithThunder : weather.moderateOrHeavySnowWithThunderNight;
      
      // Hot weather (custom condition)
      case WeatherCondition.hot:
        return weather.sunny;
      
      // Humid weather (custom condition)
      case WeatherCondition.humid:
        return isDay ? weather.partlyCloudy : weather.partlyCloudyNight;
      
      }
  }
}
