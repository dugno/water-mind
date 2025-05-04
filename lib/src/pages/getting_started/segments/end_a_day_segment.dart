import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

class EndADaySegment extends StatefulWidget {
  final Function(TimeOfDay)? onTimeSelected;
  final TimeOfDay? initialTime;

  const EndADaySegment({
    super.key,
    this.onTimeSelected,
    this.initialTime,
  });

  @override
  State<EndADaySegment> createState() => _EndADaySegmentState();
}

class _EndADaySegmentState extends State<EndADaySegment>
    with HapticFeedbackMixin {
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedAmPm;

  @override
  void initState() {
    super.initState();

    // Initialize with provided time or default to 10:00 PM
    final initialTime =
        widget.initialTime ?? const TimeOfDay(hour: 22, minute: 0);

    if (initialTime.hour >= 12) {
      _selectedHour = initialTime.hour == 12 ? 12 : initialTime.hour - 12;
      _selectedAmPm = 'PM';
    } else {
      _selectedHour = initialTime.hour == 0 ? 12 : initialTime.hour;
      _selectedAmPm = 'AM';
    }

    _selectedMinute = initialTime.minute;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update AM/PM with localized strings after context is available
    if (_selectedAmPm == 'AM') {
      _selectedAmPm = context.l10n.am;
    } else if (_selectedAmPm == 'PM') {
      _selectedAmPm = context.l10n.pm;
    }
  }

  TimeOfDay _getCurrentTimeOfDay() {
    int hour = _selectedHour;

    // Convert to 24-hour format
    if (_selectedAmPm == context.l10n.pm && hour < 12) {
      hour += 12;
    } else if (_selectedAmPm == context.l10n.am && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: _buildTimePicker(),
      ),
    );
  }

  Widget _buildTimePicker() {
    // Create controllers
    final hoursController = WheelPickerController(
      itemCount: 12,
      initialIndex: _selectedHour - 1,
    );

    final minutesController = WheelPickerController(
      itemCount: 60,
      initialIndex: _selectedMinute,
    );

    final amPmController = WheelPickerController(
      itemCount: 2,
      initialIndex: _selectedAmPm == context.l10n.am ? 0 : 1,
    );

    return SizedBox(
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
              controller: hoursController,
              selectedIndexColor: const Color(0xFF03045E),
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
                if (widget.onTimeSelected != null) {
                  widget.onTimeSelected!(_getCurrentTimeOfDay());
                }
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
              controller: minutesController,
              selectedIndexColor: const Color(0xFF03045E),
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
                if (widget.onTimeSelected != null) {
                  widget.onTimeSelected!(_getCurrentTimeOfDay());
                }
              },
            ),
          ),

          // AM/PM wheel
          Expanded(
            child: WheelPicker(
              builder: (context, index) => Text(
                index == 0 ? context.l10n.am : context.l10n.pm,
                style: const TextStyle(fontSize: 20),
              ),
              controller: amPmController,
              selectedIndexColor: const Color(0xFF03045E),
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
                  _selectedAmPm =
                      index == 0 ? context.l10n.am : context.l10n.pm;
                });
                if (widget.onTimeSelected != null) {
                  widget.onTimeSelected!(_getCurrentTimeOfDay());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
