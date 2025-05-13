import 'package:flutter/material.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:wheel_picker/wheel_picker.dart';

/// A custom time picker that shows a wheel picker for hour, minute, and AM/PM
Future<TimeOfDay?> showTimeOfDayPicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  return await showDialog<TimeOfDay>(
    context: context,
    builder: (context) => TimeOfDayPickerDialog(initialTime: initialTime),
  );
}

/// Dialog that contains the time picker
class TimeOfDayPickerDialog extends StatefulWidget {
  /// The initial time to display
  final TimeOfDay initialTime;

  /// Constructor
  const TimeOfDayPickerDialog({
    super.key,
    required this.initialTime,
  });

  @override
  State<TimeOfDayPickerDialog> createState() => _TimeOfDayPickerDialogState();
}

class _TimeOfDayPickerDialogState extends State<TimeOfDayPickerDialog>
    with HapticFeedbackMixin {
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedAmPm;

  // Controllers for wheel pickers
  late WheelPickerController _hourController;
  late WheelPickerController _minuteController;
  late WheelPickerController _amPmController;

  @override
  void initState() {
    super.initState();

    // Initialize with provided time
    if (widget.initialTime.hour >= 12) {
      _selectedHour = widget.initialTime.hour == 12 ? 12 : widget.initialTime.hour - 12;
      _selectedAmPm = 'PM';
    } else {
      _selectedHour = widget.initialTime.hour == 0 ? 12 : widget.initialTime.hour;
      _selectedAmPm = 'AM';
    }

    _selectedMinute = widget.initialTime.minute;

    // Initialize controllers
    _hourController = WheelPickerController(
      itemCount: 12,
      initialIndex: _selectedHour - 1,
    );

    _minuteController = WheelPickerController(
      itemCount: 60,
      initialIndex: _selectedMinute,
    );

    _amPmController = WheelPickerController(
      itemCount: 2,
      initialIndex: _selectedAmPm == 'AM' ? 0 : 1,
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    try {
      _hourController.dispose();
      _minuteController.dispose();
      _amPmController.dispose();
    } catch (e) {
      // Bỏ qua lỗi khi dispose controller
      debugPrint('Error disposing time picker controllers: $e');
    }
    super.dispose();
  }

  TimeOfDay _getCurrentTimeOfDay() {
    int hour = _selectedHour;

    // Convert to 24-hour format
    if (_selectedAmPm == 'PM' && hour < 12) {
      hour += 12;
    } else if (_selectedAmPm == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Time'),
      content: SizedBox(
        height: 200,
        child: Row(
          children: [
            // Hours wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) => Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 20),
                ),
                controller: _hourController,
                selectedIndexColor: Theme.of(context).colorScheme.primary,
                looping: false,
                style: const WheelPickerStyle(
                  itemExtent: 40,
                  squeeze: 1.0,
                  diameterRatio: 1.5,
                  magnification: 1.2,
                  surroundingOpacity: 0.3,
                ),
                onIndexChanged: (index, _) {
                  haptic(HapticFeedbackType.selection);
                  setState(() {
                    _selectedHour = index + 1;
                  });
                },
              ),
            ),

            // Minutes wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) => Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 20),
                ),
                controller: _minuteController,
                selectedIndexColor: Theme.of(context).colorScheme.primary,
                looping: false,
                style: const WheelPickerStyle(
                  itemExtent: 40,
                  squeeze: 1.0,
                  diameterRatio: 1.5,
                  magnification: 1.2,
                  surroundingOpacity: 0.3,
                ),
                onIndexChanged: (index, _) {
                  haptic(HapticFeedbackType.selection);
                  setState(() {
                    _selectedMinute = index;
                  });
                },
              ),
            ),

            // AM/PM wheel
            Expanded(
              child: WheelPicker(
                builder: (context, index) => Text(
                  index == 0 ? 'AM' : 'PM',
                  style: const TextStyle(fontSize: 20),
                ),
                controller: _amPmController,
                selectedIndexColor: Theme.of(context).colorScheme.primary,
                looping: false,
                style: const WheelPickerStyle(
                  itemExtent: 40,
                  squeeze: 1.0,
                  diameterRatio: 1.5,
                  magnification: 1.2,
                  surroundingOpacity: 0.3,
                ),
                onIndexChanged: (index, _) {
                  haptic(HapticFeedbackType.selection);
                  setState(() {
                    _selectedAmPm = index == 0 ? 'AM' : 'PM';
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_getCurrentTimeOfDay()),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
