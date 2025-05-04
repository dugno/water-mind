import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import '../models/wheel_picker_config.dart';
import '../models/wheel_picker_item.dart';
import '../theme/wheel_picker_theme.dart';

/// A single column in the wheel picker
class WheelPickerColumn<T> extends StatefulWidget {
  /// The items to display in the wheel picker
  final List<WheelPickerItem<T>> items;

  /// The initially selected item index
  final int initialIndex;

  /// The callback when an item is selected
  final Function(int index, T value)? onSelectedItemChanged;

  /// The configuration for the wheel picker
  final WheelPickerConfig config;

  /// The theme for the wheel picker
  final WheelPickerTheme? theme;

  /// Constructor
  const WheelPickerColumn({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onSelectedItemChanged,
    this.config = const WheelPickerConfig(),
    this.theme,
  });

  @override
  State<WheelPickerColumn<T>> createState() => _WheelPickerColumnState<T>();
}

class _WheelPickerColumnState<T> extends State<WheelPickerColumn<T>> with HapticFeedbackMixin {
  late FixedExtentScrollController _scrollController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _scrollController = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WheelPickerColumn<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the scroll controller if the items or initial index changed
    if (oldWidget.items != widget.items || oldWidget.initialIndex != widget.initialIndex) {
      final newIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
      if (_selectedIndex != newIndex) {
        _selectedIndex = newIndex;
        _scrollController.jumpToItem(_selectedIndex);
      }
    }
  }

  void _onSelectedItemChanged(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Provide haptic feedback if enabled
      if (widget.config.useHapticFeedback) {
        haptic(widget.config.selectionHapticType);
      }

      // Call the callback
      if (widget.onSelectedItemChanged != null && index >= 0 && index < widget.items.length) {
        widget.onSelectedItemChanged!(index, widget.items[index].value);
      }
    }
  }

  void _onScrollStart() {
    setState(() {
    });
  }

  void _onScrollUpdate() {
    // Provide haptic feedback if enabled
    if (widget.config.useHapticFeedback) {
      haptic(widget.config.scrollHapticType);
    }
  }

  void _onScrollEnd() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? WheelPickerTheme.fromTheme(Theme.of(context));
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;

    // Use platform-specific styling if enabled
    if (widget.config.usePlatformStyling && isIOS) {
      return _buildIOSPicker(theme);
    }

    return _buildAndroidPicker(theme);
  }

  Widget _buildIOSPicker(WheelPickerTheme theme) {
    return SizedBox(
      height: widget.config.height,
      child: CupertinoPicker(
        scrollController: _scrollController,
        itemExtent: widget.config.itemHeight,
        diameterRatio: widget.config.diameterRatio,
        backgroundColor: theme.backgroundColor,
        selectionOverlay: _buildSelectionOverlay(theme),
        onSelectedItemChanged: _onSelectedItemChanged,
        children: _buildPickerItems(theme),
      ),
    );
  }

  Widget _buildAndroidPicker(WheelPickerTheme theme) {
    return SizedBox(
      height: widget.config.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _onScrollStart();
          } else if (notification is ScrollUpdateNotification) {
            _onScrollUpdate();
          } else if (notification is ScrollEndNotification) {
            _onScrollEnd();
          }
          return false;
        },
        child: ListWheelScrollView.useDelegate(
          controller: _scrollController,
          itemExtent: widget.config.itemHeight,
          diameterRatio: widget.config.diameterRatio,
          perspective: widget.config.perspective,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: _onSelectedItemChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= widget.items.length) {
                return null;
              }

              final item = widget.items[index];
              final isSelected = index == _selectedIndex;

              return _buildItem(item, isSelected, theme);
            },
            childCount: widget.items.length,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(WheelPickerTheme theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: theme.dividerThickness,
          ),
          bottom: BorderSide(
            color: theme.dividerColor,
            width: theme.dividerThickness,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPickerItems(WheelPickerTheme theme) {
    return widget.items.map((item) {
      final isSelected = widget.items.indexOf(item) == _selectedIndex;
      return _buildItem(item, isSelected, theme);
    }).toList();
  }

  Widget _buildItem(WheelPickerItem<T> item, bool isSelected, WheelPickerTheme theme) {
    final textStyle = item.enabled
        ? (isSelected
            ? theme.selectedItemTextStyle
            : theme.unselectedItemTextStyle)
        : theme.disabledItemTextStyle;

    final textColor = item.enabled
        ? (isSelected
            ? theme.selectedItemColor
            : theme.unselectedItemColor)
        : theme.disabledItemColor;

    return Center(
      child: Text(
        item.text,
        style: textStyle?.copyWith(color: textColor) ??
            TextStyle(
              color: textColor,
              fontSize: isSelected ? 16 : 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
