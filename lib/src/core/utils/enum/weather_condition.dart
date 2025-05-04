import 'package:flutter/material.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

/// Enum representing different weather conditions based on weather API codes
enum WeatherCondition {
  /// Sunny (code: 1000)
  sunny(1000, 1.1),

  /// Partly cloudy (code: 1003)
  partlyCloudy(1003, 1.05),

  /// Cloudy (code: 1006)
  cloudy(1006, 1.0),

  /// Overcast (code: 1009)
  overcast(1009, 1.0),

  /// Mist (code: 1030)
  mist(1030, 1.05),

  /// Patchy rain possible (code: 1063)
  patchyRainPossible(1063, 1.05),

  /// Patchy snow possible (code: 1066)
  patchySnowPossible(1066, 0.95),

  /// Patchy sleet possible (code: 1069)
  patchySleetPossible(1069, 0.95),

  /// Patchy freezing drizzle possible (code: 1072)
  patchyFreezingDrizzlePossible(1072, 0.95),

  /// Thundery outbreaks possible (code: 1087)
  thunderyOutbreaksPossible(1087, 1.05),

  /// Blowing snow (code: 1114)
  blowingSnow(1114, 0.9),

  /// Blizzard (code: 1117)
  blizzard(1117, 0.9),

  /// Fog (code: 1135)
  fog(1135, 1.05),

  /// Freezing fog (code: 1147)
  freezingFog(1147, 0.95),

  /// Patchy light drizzle (code: 1150)
  patchyLightDrizzle(1150, 1.05),

  /// Light drizzle (code: 1153)
  lightDrizzle(1153, 1.05),

  /// Freezing drizzle (code: 1168)
  freezingDrizzle(1168, 0.95),

  /// Heavy freezing drizzle (code: 1171)
  heavyFreezingDrizzle(1171, 0.95),

  /// Patchy light rain (code: 1180)
  patchyLightRain(1180, 1.05),

  /// Light rain (code: 1183)
  lightRain(1183, 1.05),

  /// Moderate rain at times (code: 1186)
  moderateRainAtTimes(1186, 1.1),

  /// Moderate rain (code: 1189)
  moderateRain(1189, 1.1),

  /// Heavy rain at times (code: 1192)
  heavyRainAtTimes(1192, 1.15),

  /// Heavy rain (code: 1195)
  heavyRain(1195, 1.15),

  /// Light freezing rain (code: 1198)
  lightFreezingRain(1198, 0.95),

  /// Moderate or heavy freezing rain (code: 1201)
  moderateOrHeavyFreezingRain(1201, 0.95),

  /// Light sleet (code: 1204)
  lightSleet(1204, 0.95),

  /// Moderate or heavy sleet (code: 1207)
  moderateOrHeavySleet(1207, 0.95),

  /// Patchy light snow (code: 1210)
  patchyLightSnow(1210, 0.9),

  /// Light snow (code: 1213)
  lightSnow(1213, 0.9),

  /// Patchy moderate snow (code: 1216)
  patchyModerateSnow(1216, 0.9),

  /// Moderate snow (code: 1219)
  moderateSnow(1219, 0.9),

  /// Patchy heavy snow (code: 1222)
  patchyHeavySnow(1222, 0.9),

  /// Heavy snow (code: 1225)
  heavySnow(1225, 0.9),

  /// Ice pellets (code: 1237)
  icePellets(1237, 0.95),

  /// Light rain shower (code: 1240)
  lightRainShower(1240, 1.05),

  /// Moderate or heavy rain shower (code: 1243)
  moderateOrHeavyRainShower(1243, 1.1),

  /// Torrential rain shower (code: 1246)
  torrentialRainShower(1246, 1.15),

  /// Light sleet showers (code: 1249)
  lightSleetShowers(1249, 0.95),

  /// Moderate or heavy sleet showers (code: 1252)
  moderateOrHeavySleetShowers(1252, 0.95),

  /// Light snow showers (code: 1255)
  lightSnowShowers(1255, 0.9),

  /// Moderate or heavy snow showers (code: 1258)
  moderateOrHeavySnowShowers(1258, 0.9),

  /// Light showers of ice pellets (code: 1261)
  lightShowersOfIcePellets(1261, 0.95),

  /// Moderate or heavy showers of ice pellets (code: 1264)
  moderateOrHeavyShowersOfIcePellets(1264, 0.95),

  /// Patchy light rain with thunder (code: 1273)
  patchyLightRainWithThunder(1273, 1.1),

  /// Moderate or heavy rain with thunder (code: 1276)
  moderateOrHeavyRainWithThunder(1276, 1.15),

  /// Patchy light snow with thunder (code: 1279)
  patchyLightSnowWithThunder(1279, 0.9),

  /// Moderate or heavy snow with thunder (code: 1282)
  moderateOrHeavySnowWithThunder(1282, 0.9),

  /// Hot weather (high temperature)
  hot(2000, 1.2),

  /// Humid weather (high humidity)
  humid(2001, 1.15);

  /// The weather condition code
  final int code;

  /// The hydration factor for this weather condition
  final double hydrationFactor;

  /// Constructor
  const WeatherCondition(this.code, this.hydrationFactor);

  /// Returns the localized string representation of the weather condition
  String getString(BuildContext context) {
    // For simplicity, we'll return a basic representation
    // In a real app, you would add all these strings to your ARB files
    switch (this) {
      case WeatherCondition.sunny:
        return context.l10n.sunny;
      case WeatherCondition.partlyCloudy:
        return "Partly Cloudy";
      case WeatherCondition.cloudy:
        return context.l10n.cloudy;
      case WeatherCondition.overcast:
        return "Overcast";
      case WeatherCondition.mist:
        return "Mist";
      case WeatherCondition.patchyRainPossible:
        return "Patchy Rain";
      case WeatherCondition.patchySnowPossible:
        return "Patchy Snow";
      case WeatherCondition.patchySleetPossible:
        return "Patchy Sleet";
      case WeatherCondition.patchyFreezingDrizzlePossible:
        return "Freezing Drizzle";
      case WeatherCondition.thunderyOutbreaksPossible:
        return "Thunder Possible";
      case WeatherCondition.blowingSnow:
        return "Blowing Snow";
      case WeatherCondition.blizzard:
        return "Blizzard";
      case WeatherCondition.fog:
        return "Fog";
      case WeatherCondition.freezingFog:
        return "Freezing Fog";
      case WeatherCondition.patchyLightDrizzle:
        return "Light Drizzle";
      case WeatherCondition.lightDrizzle:
        return "Light Drizzle";
      case WeatherCondition.freezingDrizzle:
        return "Freezing Drizzle";
      case WeatherCondition.heavyFreezingDrizzle:
        return "Heavy Freezing Drizzle";
      case WeatherCondition.patchyLightRain:
        return "Light Rain";
      case WeatherCondition.lightRain:
        return "Light Rain";
      case WeatherCondition.moderateRainAtTimes:
        return "Moderate Rain";
      case WeatherCondition.moderateRain:
        return "Moderate Rain";
      case WeatherCondition.heavyRainAtTimes:
        return "Heavy Rain";
      case WeatherCondition.heavyRain:
        return "Heavy Rain";
      case WeatherCondition.lightFreezingRain:
        return "Light Freezing Rain";
      case WeatherCondition.moderateOrHeavyFreezingRain:
        return "Heavy Freezing Rain";
      case WeatherCondition.lightSleet:
        return "Light Sleet";
      case WeatherCondition.moderateOrHeavySleet:
        return "Heavy Sleet";
      case WeatherCondition.patchyLightSnow:
        return "Light Snow";
      case WeatherCondition.lightSnow:
        return "Light Snow";
      case WeatherCondition.patchyModerateSnow:
        return "Moderate Snow";
      case WeatherCondition.moderateSnow:
        return "Moderate Snow";
      case WeatherCondition.patchyHeavySnow:
        return "Heavy Snow";
      case WeatherCondition.heavySnow:
        return "Heavy Snow";
      case WeatherCondition.icePellets:
        return "Ice Pellets";
      case WeatherCondition.lightRainShower:
        return "Light Rain Shower";
      case WeatherCondition.moderateOrHeavyRainShower:
        return "Heavy Rain Shower";
      case WeatherCondition.torrentialRainShower:
        return "Torrential Rain";
      case WeatherCondition.lightSleetShowers:
        return "Light Sleet Showers";
      case WeatherCondition.moderateOrHeavySleetShowers:
        return "Heavy Sleet Showers";
      case WeatherCondition.lightSnowShowers:
        return "Light Snow Showers";
      case WeatherCondition.moderateOrHeavySnowShowers:
        return "Heavy Snow Showers";
      case WeatherCondition.lightShowersOfIcePellets:
        return "Light Ice Pellets";
      case WeatherCondition.moderateOrHeavyShowersOfIcePellets:
        return "Heavy Ice Pellets";
      case WeatherCondition.patchyLightRainWithThunder:
        return "Light Rain with Thunder";
      case WeatherCondition.moderateOrHeavyRainWithThunder:
        return "Heavy Rain with Thunder";
      case WeatherCondition.patchyLightSnowWithThunder:
        return "Light Snow with Thunder";
      case WeatherCondition.moderateOrHeavySnowWithThunder:
        return "Heavy Snow with Thunder";
      case WeatherCondition.hot:
        return context.l10n.hot;
      case WeatherCondition.humid:
        return context.l10n.humid;
    }
  }

  /// Get the hydration factor for this weather condition
  double getHydrationFactor() {
    // The hydration factor is now stored as a property
    return hydrationFactor;
  }

  /// Get the icon for this weather condition
  IconData getIcon() {
    // For simplicity, we'll map weather conditions to basic icons
    // In a real app, you would have more specific icons
    if (code == 1000) {
      // Sunny
      return Icons.wb_sunny;
    } else if (code >= 1003 && code <= 1009) {
      // Cloudy conditions
      return Icons.cloud;
    } else if (code >= 1030 && code <= 1135) {
      // Fog, mist
      return Icons.cloud;
    } else if (code >= 1150 && code <= 1201) {
      // Rain, drizzle
      return Icons.water_drop;
    } else if (code >= 1204 && code <= 1237) {
      // Snow, sleet, ice
      return Icons.ac_unit;
    } else if (code >= 1240 && code <= 1264) {
      // Showers
      return Icons.water_drop;
    } else if (code >= 1273 && code <= 1282) {
      // Thunder
      return Icons.thunderstorm;
    } else if (this == WeatherCondition.hot) {
      return Icons.thermostat;
    } else if (this == WeatherCondition.humid) {
      return Icons.water;
    } else {
      return Icons.cloud;
    }
  }

  /// Find a weather condition by its code
  static WeatherCondition fromCode(int code) {
    try {
      return WeatherCondition.values
          .firstWhere((condition) => condition.code == code);
    } catch (e) {
      // Default to cloudy if code not found
      return WeatherCondition.cloudy;
    }
  }
}
