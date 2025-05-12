import 'package:flutter/widgets.dart';

/// Represents an item in the wheel picker
class WheelPickerItem<T> {
  /// The value of the item
  final T value;

  /// The text to display for the item
  final String? text;

  /// Whether the item is enabled
  final bool enabled;

  /// Custom widget to display for the item (optional)
  /// If provided, this widget will be used instead of the default text
  final Widget? widget;

  /// Constructor
  const WheelPickerItem({
    required this.value,
    this.text,
    this.enabled = true,
    this.widget,
  });
}
