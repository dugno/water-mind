/// Represents an item in the wheel picker
class WheelPickerItem<T> {
  /// The value of the item
  final T value;

  /// The text to display for the item
  final String text;

  /// Whether the item is enabled
  final bool enabled;

  /// Constructor
  const WheelPickerItem({
    required this.value,
    required this.text,
    this.enabled = true,
  });
}
