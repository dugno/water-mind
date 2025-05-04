import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/platform.dart';

/// Enum defining different device types based on screen width
enum DeviceType {
  /// Mobile devices (phones) - width < 600dp
  mobile,

  /// Tablet devices - width >= 600dp and < 1200dp
  tablet,

  /// Desktop devices - width >= 1200dp
  desktop,
}

/// Enum defining different screen size breakpoints
enum ScreenSize {
  /// Extra small screens (small phones) - width < 360dp
  xs,

  /// Small screens (normal phones) - width >= 360dp and < 600dp
  sm,

  /// Medium screens (large phones, small tablets) - width >= 600dp and < 840dp
  md,

  /// Large screens (tablets) - width >= 840dp and < 1200dp
  lg,

  /// Extra large screens (desktops, large tablets) - width >= 1200dp
  xl,

  /// Extra extra large screens (large desktops) - width >= 1440dp
  xxl,
}

/// A utility class for responsive UI design
///
/// This class provides methods and properties to help create responsive UIs
/// that adapt to different screen sizes and orientations.
class ScreenUtils {
  /// Private constructor to prevent instantiation
  ScreenUtils._();

  /// Singleton instance
  static final ScreenUtils _instance = ScreenUtils._();

  /// Factory constructor to return the singleton instance
  factory ScreenUtils() => _instance;

  /// Get the current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get the current screen size category based on screen width
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      return ScreenSize.xs;
    } else if (width < 600) {
      return ScreenSize.sm;
    } else if (width < 840) {
      return ScreenSize.md;
    } else if (width < 1200) {
      return ScreenSize.lg;
    } else if (width < 1440) {
      return ScreenSize.xl;
    } else {
      return ScreenSize.xxl;
    }
  }

  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get a responsive value based on screen size
  ///
  /// [xs] - Value for extra small screens
  /// [sm] - Value for small screens
  /// [md] - Value for medium screens
  /// [lg] - Value for large screens
  /// [xl] - Value for extra large screens
  /// [xxl] - Value for extra extra large screens
  static T responsive<T>(
    BuildContext context, {
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
    T? xxl,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.xs:
        return xs;
      case ScreenSize.sm:
        return sm ?? xs;
      case ScreenSize.md:
        return md ?? sm ?? xs;
      case ScreenSize.lg:
        return lg ?? md ?? sm ?? xs;
      case ScreenSize.xl:
        return xl ?? lg ?? md ?? sm ?? xs;
      case ScreenSize.xxl:
        return xxl ?? xl ?? lg ?? md ?? sm ?? xs;
    }
  }

  /// Calculate a responsive font size based on screen width
  ///
  /// [size] - Base font size
  /// [minSize] - Minimum font size (optional)
  /// [maxSize] - Maximum font size (optional)
  static double responsiveFontSize(
    BuildContext context, {
    required double size,
    double? minSize,
    double? maxSize,
  }) {
    final width = MediaQuery.of(context).size.width;
    final calculatedSize = size * (width / 375); // 375 is base width (iPhone)
    
    if (minSize != null && calculatedSize < minSize) {
      return minSize;
    }
    
    if (maxSize != null && calculatedSize > maxSize) {
      return maxSize;
    }
    
    return calculatedSize;
  }

  /// Calculate a responsive value based on screen width percentage
  ///
  /// [percentage] - Percentage of screen width (0-100)
  static double widthPercent(BuildContext context, double percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * (percentage / 100);
  }

  /// Calculate a responsive value based on screen height percentage
  ///
  /// [percentage] - Percentage of screen height (0-100)
  static double heightPercent(BuildContext context, double percentage) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * (percentage / 100);
  }

  /// Get the screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get the screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get the screen padding (safe area)
  static EdgeInsets screenPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get the screen device pixel ratio
  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Check if the device is a mobile device based on platform
  static bool get isMobileDevice => kIsAndroid || kIsIOS;

  /// Check if the device is a desktop device based on platform
  static bool get isDesktopDevice => kIsMacOS || kIsWindows || kIsLinux;

  /// Check if the device has a notch (only for iOS)
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 20;
  }
}
