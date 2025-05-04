import 'package:flutter/material.dart';
import 'screen_utils.dart';
import 'responsive_extension.dart';

/// A widget that builds different widgets based on the screen size
class ResponsiveBuilder extends StatelessWidget {
  /// Widget to display on mobile devices
  final Widget mobile;

  /// Widget to display on tablet devices (optional)
  final Widget? tablet;

  /// Widget to display on desktop devices (optional)
  final Widget? desktop;

  /// Creates a responsive builder widget
  ///
  /// [mobile] is required and will be used as a fallback for other device types
  /// if they are not provided.
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ScreenUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
      default:
        return mobile;
    }
  }
}

/// A widget that builds different widgets based on the screen size category
class ResponsiveScreenBuilder extends StatelessWidget {
  /// Widget to display on extra small screens
  final Widget xs;

  /// Widget to display on small screens (optional)
  final Widget? sm;

  /// Widget to display on medium screens (optional)
  final Widget? md;

  /// Widget to display on large screens (optional)
  final Widget? lg;

  /// Widget to display on extra large screens (optional)
  final Widget? xl;

  /// Widget to display on extra extra large screens (optional)
  final Widget? xxl;

  /// Creates a responsive screen builder widget
  ///
  /// [xs] is required and will be used as a fallback for other screen sizes
  /// if they are not provided.
  const ResponsiveScreenBuilder({
    super.key,
    required this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.xxl,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSizeType;

    switch (screenSize) {
      case ScreenSize.xxl:
        return xxl ?? xl ?? lg ?? md ?? sm ?? xs;
      case ScreenSize.xl:
        return xl ?? lg ?? md ?? sm ?? xs;
      case ScreenSize.lg:
        return lg ?? md ?? sm ?? xs;
      case ScreenSize.md:
        return md ?? sm ?? xs;
      case ScreenSize.sm:
        return sm ?? xs;
      case ScreenSize.xs:
      default:
        return xs;
    }
  }
}

/// A widget that builds different widgets based on the orientation
class ResponsiveOrientationBuilder extends StatelessWidget {
  /// Widget to display in portrait orientation
  final Widget portrait;

  /// Widget to display in landscape orientation (optional)
  final Widget? landscape;

  /// Creates a responsive orientation builder widget
  ///
  /// [portrait] is required and will be used as a fallback for landscape
  /// if it is not provided.
  const ResponsiveOrientationBuilder({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;

    return isLandscape ? (landscape ?? portrait) : portrait;
  }
}

/// A responsive padding widget that adapts to screen size
class ResponsivePadding extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// Padding for extra small screens
  final EdgeInsets xs;

  /// Padding for small screens (optional)
  final EdgeInsets? sm;

  /// Padding for medium screens (optional)
  final EdgeInsets? md;

  /// Padding for large screens (optional)
  final EdgeInsets? lg;

  /// Padding for extra large screens (optional)
  final EdgeInsets? xl;

  /// Padding for extra extra large screens (optional)
  final EdgeInsets? xxl;

  /// Creates a responsive padding widget
  ///
  /// [xs] is required and will be used as a fallback for other screen sizes
  /// if they are not provided.
  const ResponsivePadding({
    super.key,
    required this.child,
    required this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.xxl,
  });

  @override
  Widget build(BuildContext context) {
    final padding = context.responsive<EdgeInsets>(
      xs: xs,
      sm: sm,
      md: md,
      lg: lg,
      xl: xl,
      xxl: xxl,
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// A responsive container widget that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  /// Child widget
  final Widget child;

  /// Width for extra small screens (percentage of screen width)
  final double? xsWidth;

  /// Width for small screens (percentage of screen width)
  final double? smWidth;

  /// Width for medium screens (percentage of screen width)
  final double? mdWidth;

  /// Width for large screens (percentage of screen width)
  final double? lgWidth;

  /// Width for extra large screens (percentage of screen width)
  final double? xlWidth;

  /// Width for extra extra large screens (percentage of screen width)
  final double? xxlWidth;

  /// Maximum width of the container
  final double? maxWidth;

  /// Creates a responsive container widget
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.xsWidth,
    this.smWidth,
    this.mdWidth,
    this.lgWidth,
    this.xlWidth,
    this.xxlWidth,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    double? width;

    // Calculate width based on screen size
    if (context.isExtraExtraLargeScreen && xxlWidth != null) {
      width = context.widthPercent(xxlWidth!);
    } else if (context.isExtraLargeScreen && xlWidth != null) {
      width = context.widthPercent(xlWidth!);
    } else if (context.isLargeScreen && lgWidth != null) {
      width = context.widthPercent(lgWidth!);
    } else if (context.isMediumScreen && mdWidth != null) {
      width = context.widthPercent(mdWidth!);
    } else if (context.isSmallScreen && smWidth != null) {
      width = context.widthPercent(smWidth!);
    } else if (context.isExtraSmallScreen && xsWidth != null) {
      width = context.widthPercent(xsWidth!);
    }

    // Apply max width constraint if provided
    if (width != null && maxWidth != null && width > maxWidth!) {
      width = maxWidth;
    }

    return Container(
      width: width,
      child: child,
    );
  }
}

/// A responsive text widget that adapts font size to screen size
class ResponsiveText extends StatelessWidget {
  /// Text to display
  final String text;

  /// Text style
  final TextStyle? style;

  /// Base font size
  final double fontSize;

  /// Minimum font size
  final double? minFontSize;

  /// Maximum font size
  final double? maxFontSize;

  /// Text alignment
  final TextAlign? textAlign;

  /// Text overflow behavior
  final TextOverflow? overflow;

  /// Maximum number of lines
  final int? maxLines;

  /// Creates a responsive text widget
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    required this.fontSize,
    this.minFontSize,
    this.maxFontSize,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = context.responsiveFontSize(
      size: fontSize,
      minSize: minFontSize,
      maxSize: maxFontSize,
    );

    return Text(
      text,
      style: style?.copyWith(fontSize: responsiveFontSize) ??
             TextStyle(fontSize: responsiveFontSize),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
