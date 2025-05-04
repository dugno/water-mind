import 'package:flutter/material.dart';

/// Theme for the wheel picker
class WheelPickerTheme {
  /// The background color of the wheel picker
  final Color backgroundColor;

  /// The color of the selected item
  final Color selectedItemColor;

  /// The color of unselected items
  final Color unselectedItemColor;

  /// The color of disabled items
  final Color disabledItemColor;

  /// The text style for the selected item
  final TextStyle? selectedItemTextStyle;

  /// The text style for unselected items
  final TextStyle? unselectedItemTextStyle;

  /// The text style for disabled items
  final TextStyle? disabledItemTextStyle;

  /// The color of the divider
  final Color dividerColor;

  /// The thickness of the divider
  final double dividerThickness;

  /// Constructor
  const WheelPickerTheme({
    this.backgroundColor = Colors.white,
    this.selectedItemColor = Colors.black,
    this.unselectedItemColor = Colors.black54,
    this.disabledItemColor = Colors.grey,
    this.selectedItemTextStyle,
    this.unselectedItemTextStyle,
    this.disabledItemTextStyle,
    this.dividerColor = Colors.grey,
    this.dividerThickness = 1.0,
  });

  /// Create a theme from the app theme
  factory WheelPickerTheme.fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return WheelPickerTheme(
      backgroundColor: theme.scaffoldBackgroundColor,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.7),
      disabledItemColor: colorScheme.onSurface.withOpacity(0.3),
      selectedItemTextStyle: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
      unselectedItemTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.7),
      ),
      disabledItemTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.3),
      ),
      dividerColor: colorScheme.outline,
      dividerThickness: 1.0,
    );
  }

  /// Create a copy of this theme with the given fields replaced
  WheelPickerTheme copyWith({
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    Color? disabledItemColor,
    TextStyle? selectedItemTextStyle,
    TextStyle? unselectedItemTextStyle,
    TextStyle? disabledItemTextStyle,
    Color? dividerColor,
    double? dividerThickness,
  }) {
    return WheelPickerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
      disabledItemColor: disabledItemColor ?? this.disabledItemColor,
      selectedItemTextStyle: selectedItemTextStyle ?? this.selectedItemTextStyle,
      unselectedItemTextStyle: unselectedItemTextStyle ?? this.unselectedItemTextStyle,
      disabledItemTextStyle: disabledItemTextStyle ?? this.disabledItemTextStyle,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
    );
  }
}
