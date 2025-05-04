import 'package:flutter/material.dart';
import 'screen_utils.dart';

/// Extension methods on BuildContext for responsive design
extension ResponsiveExtension on BuildContext {
  /// Get the MediaQueryData from the current context
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get the screen size
  Size get screenSize => mediaQuery.size;

  /// Get the screen width
  double get screenWidth => screenSize.width;

  /// Get the screen height
  double get screenHeight => screenSize.height;

  /// Get the device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Get the screen padding (safe area)
  EdgeInsets get screenPadding => mediaQuery.padding;

  /// Get the screen view insets (keyboard area)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Get the screen view padding
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  /// Get the current device type
  DeviceType get deviceType => ScreenUtils.getDeviceType(this);

  /// Get the current screen size category
  ScreenSize get screenSizeType => ScreenUtils.getScreenSize(this);

  /// Check if the device is in landscape orientation
  bool get isLandscape => ScreenUtils.isLandscape(this);

  /// Check if the device is in portrait orientation
  bool get isPortrait => ScreenUtils.isPortrait(this);

  /// Check if the current device is a mobile phone
  bool get isMobile => deviceType == DeviceType.mobile;

  /// Check if the current device is a tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Check if the current device is a desktop
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Check if the screen size is extra small
  bool get isExtraSmallScreen => screenSizeType == ScreenSize.xs;

  /// Check if the screen size is small
  bool get isSmallScreen => screenSizeType == ScreenSize.sm;

  /// Check if the screen size is medium
  bool get isMediumScreen => screenSizeType == ScreenSize.md;

  /// Check if the screen size is large
  bool get isLargeScreen => screenSizeType == ScreenSize.lg;

  /// Check if the screen size is extra large
  bool get isExtraLargeScreen => screenSizeType == ScreenSize.xl;

  /// Check if the screen size is extra extra large
  bool get isExtraExtraLargeScreen => screenSizeType == ScreenSize.xxl;

  /// Calculate a responsive value based on screen width percentage
  ///
  /// [percentage] - Percentage of screen width (0-100)
  double widthPercent(double percentage) => ScreenUtils.widthPercent(this, percentage);

  /// Calculate a responsive value based on screen height percentage
  ///
  /// [percentage] - Percentage of screen height (0-100)
  double heightPercent(double percentage) => ScreenUtils.heightPercent(this, percentage);

  /// Calculate a responsive font size based on screen width
  ///
  /// [size] - Base font size
  /// [minSize] - Minimum font size (optional)
  /// [maxSize] - Maximum font size (optional)
  double responsiveFontSize({
    required double size,
    double? minSize,
    double? maxSize,
  }) => ScreenUtils.responsiveFontSize(
    this,
    size: size,
    minSize: minSize,
    maxSize: maxSize,
  );

  /// Get a responsive value based on screen size
  ///
  /// [xs] - Value for extra small screens
  /// [sm] - Value for small screens
  /// [md] - Value for medium screens
  /// [lg] - Value for large screens
  /// [xl] - Value for extra large screens
  /// [xxl] - Value for extra extra large screens
  T responsive<T>({
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
    T? xxl,
  }) => ScreenUtils.responsive(
    this,
    xs: xs,
    sm: sm,
    md: md,
    lg: lg,
    xl: xl,
    xxl: xxl,
  );

  /// Check if the device has a notch (only for iOS)
  bool get hasNotch => ScreenUtils.hasNotch(this);

  /// Get the top padding of the screen (including status bar)
  double get topPadding => screenPadding.top;

  /// Get the bottom padding of the screen (including navigation bar)
  double get bottomPadding => screenPadding.bottom;
}
