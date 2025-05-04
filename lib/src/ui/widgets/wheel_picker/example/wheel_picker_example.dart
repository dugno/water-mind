import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import '../wheel_picker.dart';

/// Example screen for the wheel picker
@RoutePage()
class WheelPickerExamplePage extends StatefulWidget {
  /// Constructor
  const WheelPickerExamplePage({super.key});

  @override
  State<WheelPickerExamplePage> createState() => _WheelPickerExampleState();
}

class _WheelPickerExampleState extends State<WheelPickerExamplePage>
    with HapticFeedbackMixin {
  // Selected values
  int _selectedHour = 12;
  int _selectedMinute = 0;
  String _selectedAmPm = 'AM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheel Picker Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display selected time
            Text(
              'Selected Time: $_selectedHour:${_selectedMinute.toString().padLeft(2, '0')} $_selectedAmPm',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 32),

            // Time picker
            _buildTimePicker(),

            const SizedBox(height: 32),

            // Button to confirm selection
            ElevatedButton(
              onPressed: _onConfirm,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    // Hours column
    final List<WheelPickerItem<int>> hours = List.generate(
      12,
      (index) => WheelPickerItem<int>(
        value: index + 1,
        text: (index + 1).toString(),
      ),
    );

    // Minutes column
    final List<WheelPickerItem<int>> minutes = List.generate(
      60,
      (index) => WheelPickerItem<int>(
        value: index,
        text: index.toString().padLeft(2, '0'),
      ),
    );

    // AM/PM column
    final List<WheelPickerItem<String>> amPm = [
      const WheelPickerItem<String>(value: 'AM', text: 'AM'),
      const WheelPickerItem<String>(value: 'PM', text: 'PM'),
    ];

    // Initial indices
    final List<int> initialIndices = [
      _selectedHour - 1,
      _selectedMinute,
      _selectedAmPm == 'AM' ? 0 : 1,
    ];

    return SizedBox(
      height: 200,
      child: WheelPicker(
        columns: [hours, minutes, amPm],
        initialIndices: initialIndices,
        onSelectedItemChanged: _onTimeChanged,
        config: const WheelPickerConfig(
          useHapticFeedback: true,
          scrollHapticType: HapticFeedbackType.heavy,
          selectionHapticType: HapticFeedbackType.medium,
        ),
      ),
    );
  }

  void _onTimeChanged(int columnIndex, int itemIndex, dynamic value) {
    setState(() {
      switch (columnIndex) {
        case 0: // Hours
          _selectedHour = value as int;
          break;
        case 1: // Minutes
          _selectedMinute = value as int;
          break;
        case 2: // AM/PM
          _selectedAmPm = value as String;
          break;
      }
    });

    // Provide haptic feedback
    haptic(HapticFeedbackType.selection);
  }

  void _onConfirm() {
    // Provide haptic feedback
    haptic(HapticFeedbackType.heavy);

    // Show a snackbar with the selected time
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Time selected: $_selectedHour:${_selectedMinute.toString().padLeft(2, '0')} $_selectedAmPm'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
