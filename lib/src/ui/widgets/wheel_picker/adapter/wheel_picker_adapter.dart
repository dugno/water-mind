import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart' as lib;
import '../models/wheel_picker_config.dart';
import '../models/wheel_picker_item.dart';
import '../theme/wheel_picker_theme.dart';

/// Adapter class to convert from custom WheelPicker to library WheelPicker
class WheelPicker extends StatefulWidget {
  /// The columns of items to display in the wheel picker
  final List<List<WheelPickerItem>> columns;

  /// The initially selected item indices for each column
  final List<int> initialIndices;

  /// The callback when an item is selected in any column
  final Function(int columnIndex, int itemIndex, dynamic value)? onSelectedItemChanged;

  /// The configuration for the wheel picker
  final WheelPickerConfig config;

  /// The theme for the wheel picker
  final WheelPickerTheme? theme;

  /// Constructor
  const WheelPicker({
    super.key,
    required this.columns,
    this.initialIndices = const [],
    this.onSelectedItemChanged,
    this.config = const WheelPickerConfig(),
    this.theme,
  });

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late List<lib.WheelPickerController> _controllers;
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndices();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(WheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected indices if columns or initial indices changed
    if (oldWidget.columns != widget.columns ||
        oldWidget.initialIndices != widget.initialIndices) {
      _initializeSelectedIndices();
      _disposeControllers();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  void _initializeSelectedIndices() {
    _selectedIndices = List.filled(widget.columns.length, 0);

    // Set initial indices if provided
    for (int i = 0; i < widget.initialIndices.length && i < widget.columns.length; i++) {
      final columnLength = widget.columns[i].length;
      if (columnLength > 0) {
        _selectedIndices[i] = widget.initialIndices[i].clamp(0, columnLength - 1);
      }
    }
  }

  void _initializeControllers() {
    _controllers = List.generate(widget.columns.length, (columnIndex) {
      final column = widget.columns[columnIndex];
      final initialIndex = columnIndex < _selectedIndices.length
          ? _selectedIndices[columnIndex]
          : 0;

      return lib.WheelPickerController(
        itemCount: column.length,
        initialIndex: initialIndex,
      );
    });
  }

  void _onColumnItemChanged(int columnIndex, int itemIndex) {
    setState(() {
      _selectedIndices[columnIndex] = itemIndex;
    });

    // Call the callback
    if (widget.onSelectedItemChanged != null) {
      final value = widget.columns[columnIndex][itemIndex].value;
      widget.onSelectedItemChanged!(columnIndex, itemIndex, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? WheelPickerTheme.fromTheme(Theme.of(context));

    return Container(
      height: widget.config.height,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: _buildColumns(theme),
      ),
    );
  }

  List<Widget> _buildColumns(WheelPickerTheme theme) {
    final List<Widget> columnWidgets = [];

    for (int i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];

      columnWidgets.add(
        Expanded(
          child: _buildWheelPickerColumn(i, column, theme),
        ),
      );

      // Add divider between columns
      if (i < widget.columns.length - 1) {
        columnWidgets.add(
          VerticalDivider(
            width: 1,
            thickness: theme.dividerThickness,
            color: theme.dividerColor,
          ),
        );
      }
    }

    return columnWidgets;
  }

  Widget _buildWheelPickerColumn(int columnIndex, List<WheelPickerItem> items, WheelPickerTheme theme) {
    return lib.WheelPicker(
      builder: (context, index) {
        final item = items[index];

        // Use custom widget if provided, otherwise use text
        if (item.widget != null) {
          return item.widget!;
        } else {
          final isEnabled = item.enabled;
          final textStyle = isEnabled
              ? theme.selectedItemTextStyle
              : theme.disabledItemTextStyle;

          return Text(
            item.text ?? '',
            style: textStyle,
          );
        }
      },
      controller: _controllers[columnIndex],
      selectedIndexColor: theme.selectedItemColor,
      looping: false,
      style: lib.WheelPickerStyle(
        itemExtent: widget.config.itemHeight,
        squeeze: 1.0,
        diameterRatio: widget.config.diameterRatio,
        magnification: 1.2,
        surroundingOpacity: 0.3,
      ),
      onIndexChanged: (index, _) {
        if (widget.config.useHapticFeedback) {
          // Haptic feedback is handled in the onIndexChanged callback
          // We'll rely on the implementation in the calling code
        }
        _onColumnItemChanged(columnIndex, index);
      },
    );
  }
}
