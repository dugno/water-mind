import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/haptic/haptic.dart';
import '../models/wheel_picker_config.dart';
import '../models/wheel_picker_item.dart';
import '../theme/wheel_picker_theme.dart';
import 'wheel_picker_column.dart';

/// A customizable wheel picker with haptic feedback
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
   WheelPicker({
    super.key,
    required this.columns,
    this.initialIndices = const [],
    this.onSelectedItemChanged,
    this.config = const WheelPickerConfig(),
    this.theme,
  }) : assert(columns.isNotEmpty, 'At least one column must be provided');

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> with HapticFeedbackMixin {
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndices();
  }

  @override
  void didUpdateWidget(WheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update selected indices if columns or initial indices changed
    if (oldWidget.columns != widget.columns || 
        oldWidget.initialIndices != widget.initialIndices) {
      _initializeSelectedIndices();
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

  void _onColumnItemChanged(int columnIndex, int itemIndex, dynamic value) {
    setState(() {
      _selectedIndices[columnIndex] = itemIndex;
    });
    
    // Call the callback
    if (widget.onSelectedItemChanged != null) {
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
      final initialIndex = i < _selectedIndices.length ? _selectedIndices[i] : 0;
      
      columnWidgets.add(
        Expanded(
          child: WheelPickerColumn(
            items: column,
            initialIndex: initialIndex,
            onSelectedItemChanged: (index, value) => 
                _onColumnItemChanged(i, index, value),
            config: widget.config,
            theme: theme,
          ),
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
}
