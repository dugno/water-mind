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
    final l10n = context.l10n;

    switch (this) {
      case WeatherCondition.sunny:
        return l10n.sunny;
      case WeatherCondition.partlyCloudy:
        return l10n.partlyCloudy;
      case WeatherCondition.cloudy:
        return l10n.cloudy;
      case WeatherCondition.overcast:
        return l10n.overcast;
      case WeatherCondition.mist:
        return l10n.mist;
      case WeatherCondition.patchyRainPossible:
        return l10n.patchyRain;
      case WeatherCondition.patchySnowPossible:
        return l10n.patchySnow;
      case WeatherCondition.patchySleetPossible:
        return l10n.patchySleet;
      case WeatherCondition.patchyFreezingDrizzlePossible:
        return l10n.freezingDrizzle;
      case WeatherCondition.thunderyOutbreaksPossible:
        return l10n.thunderPossible;
      case WeatherCondition.blowingSnow:
        return l10n.blowingSnow;
      case WeatherCondition.blizzard:
        return l10n.blizzard;
      case WeatherCondition.fog:
        return l10n.fog;
      case WeatherCondition.freezingFog:
        return l10n.freezingFog;
      case WeatherCondition.patchyLightDrizzle:
        return l10n.lightDrizzle;
      case WeatherCondition.lightDrizzle:
        return l10n.lightDrizzle;
      case WeatherCondition.freezingDrizzle:
        return l10n.freezingDrizzle;
      case WeatherCondition.heavyFreezingDrizzle:
        return l10n.heavyFreezingDrizzle;
      case WeatherCondition.patchyLightRain:
        return l10n.lightRain;
      case WeatherCondition.lightRain:
        return l10n.lightRain;
      case WeatherCondition.moderateRainAtTimes:
        return l10n.moderateRain;
      case WeatherCondition.moderateRain:
        return l10n.moderateRain;
      case WeatherCondition.heavyRainAtTimes:
        return l10n.heavyRain;
      case WeatherCondition.heavyRain:
        return l10n.heavyRain;
      case WeatherCondition.lightFreezingRain:
        return l10n.lightFreezingRain;
      case WeatherCondition.moderateOrHeavyFreezingRain:
        return l10n.heavyFreezingRain;
      case WeatherCondition.lightSleet:
        return l10n.lightSleet;
      case WeatherCondition.moderateOrHeavySleet:
        return l10n.heavySleet;
      case WeatherCondition.patchyLightSnow:
        return l10n.lightSnow;
      case WeatherCondition.lightSnow:
        return l10n.lightSnow;
      case WeatherCondition.patchyModerateSnow:
        return l10n.moderateSnow;
      case WeatherCondition.moderateSnow:
        return l10n.moderateSnow;
      case WeatherCondition.patchyHeavySnow:
        return l10n.heavySnow;
      case WeatherCondition.heavySnow:
        return l10n.heavySnow;
      case WeatherCondition.icePellets:
        return l10n.icePellets;
      case WeatherCondition.lightRainShower:
        return l10n.lightRainShower;
      case WeatherCondition.moderateOrHeavyRainShower:
        return l10n.heavyRainShower;
      case WeatherCondition.torrentialRainShower:
        return l10n.torrentialRain;
      case WeatherCondition.lightSleetShowers:
        return l10n.lightSleetShowers;
      case WeatherCondition.moderateOrHeavySleetShowers:
        return l10n.heavySleetShowers;
      case WeatherCondition.lightSnowShowers:
        return l10n.lightSnowShowers;
      case WeatherCondition.moderateOrHeavySnowShowers:
        return l10n.heavySnowShowers;
      case WeatherCondition.lightShowersOfIcePellets:
        return l10n.lightIcePellets;
      case WeatherCondition.moderateOrHeavyShowersOfIcePellets:
        return l10n.heavyIcePellets;
      case WeatherCondition.patchyLightRainWithThunder:
        return l10n.lightRainThunder;
      case WeatherCondition.moderateOrHeavyRainWithThunder:
        return l10n.heavyRainThunder;
      case WeatherCondition.patchyLightSnowWithThunder:
        return l10n.lightSnowThunder;
      case WeatherCondition.moderateOrHeavySnowWithThunder:
        return l10n.heavySnowThunder;
      case WeatherCondition.hot:
        return l10n.hot;
      case WeatherCondition.humid:
        return l10n.humid;
    }
  }

  /// Get the hydration factor for this weather condition
  double getHydrationFactor() {
    // The hydration factor is now stored as a property
    return hydrationFactor;
  }
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
