import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_config.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_item.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/widgets/wheel_picker.dart';

/// Bottom sheet for selecting time
class TimePickerBottomSheet extends StatefulWidget {
  /// Initial time
  final TimeOfDay initialTime;

  /// Title of the bottom sheet
  final String title;

  /// Callback when time is saved
  final Function(TimeOfDay) onSaved;

  /// Constructor
  const TimePickerBottomSheet({
    super.key,
    required this.initialTime,
    required this.title,
    required this.onSaved,
  });

  /// Show the time picker bottom sheet
  static Future<void> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    required String title,
    required Function(TimeOfDay) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      backgroundColor: AppColor.thirdColor,
      maxHeightFactor: 0.7,
      child: TimePickerBottomSheet(
        initialTime: initialTime,
        title: title,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> with HapticFeedbackMixin {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAm;

  @override
  void initState() {
    super.initState();
    
    // Convert 24-hour format to 12-hour format
    final hour = widget.initialTime.hour;
    _isAm = hour < 12;
    _selectedHour = _isAm ? (hour == 0 ? 12 : hour) : (hour == 12 ? 12 : hour - 12);
    _selectedMinute = widget.initialTime.minute;
  }

  TimeOfDay _getSelectedTime() {
    // Convert back to 24-hour format
    int hour;
    if (_isAm) {
      hour = _selectedHour == 12 ? 0 : _selectedHour;
    } else {
      hour = _selectedHour == 12 ? 12 : _selectedHour + 12;
    }
    
    return TimeOfDay(hour: hour, minute: _selectedMinute);
  }

  Widget _buildTimePicker() {
    // Create hours items (1-12)
    final List<WheelPickerItem<int>> hoursItems = List.generate(
      12,
      (index) => WheelPickerItem<int>(
        value: index + 1,
        text: '${index + 1}',
      ),
    );
    
    // Create minutes items (0-59)
    final List<WheelPickerItem<int>> minutesItems = List.generate(
      60,
      (index) => WheelPickerItem<int>(
        value: index,
        text: index.toString().padLeft(2, '0'),
      ),
    );
    
    // Create AM/PM items
    final List<WheelPickerItem<bool>> amPmItems = [
      WheelPickerItem<bool>(
        value: true,
        text: 'AM',
      ),
      WheelPickerItem<bool>(
        value: false,
        text: 'PM',
      ),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hours wheel
        Expanded(
          child: SizedBox(
            height: 200,
            child: WheelPicker(
              columns: [hoursItems],
              initialIndices: [_selectedHour - 1],
              onSelectedItemChanged: (columnIndex, itemIndex, value) {
                haptic(HapticFeedbackType.selection);
                setState(() {
                  _selectedHour = value as int;
                });
              },
              config: const WheelPickerConfig(
                height: 200,
                useHapticFeedback: true,
                itemHeight: 50,
              ),
            ),
          ),
        ),
        
        // Minutes wheel
        Expanded(
          child: SizedBox(
            height: 200,
            child: WheelPicker(
              columns: [minutesItems],
              initialIndices: [_selectedMinute],
              onSelectedItemChanged: (columnIndex, itemIndex, value) {
                haptic(HapticFeedbackType.selection);
                setState(() {
                  _selectedMinute = value as int;
                });
              },
              config: const WheelPickerConfig(
                height: 200,
                useHapticFeedback: true,
                itemHeight: 50,
              ),
            ),
          ),
        ),
        
        // AM/PM wheel
        Expanded(
          child: SizedBox(
            height: 200,
            child: WheelPicker(
              columns: [amPmItems],
              initialIndices: [_isAm ? 0 : 1],
              onSelectedItemChanged: (columnIndex, itemIndex, value) {
                haptic(HapticFeedbackType.selection);
                setState(() {
                  _isAm = value as bool;
                });
              },
              config: const WheelPickerConfig(
                height: 200,
                useHapticFeedback: true,
                itemHeight: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Current time display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isAm ? 'AM' : 'PM'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Time picker
        _buildTimePicker(),
        
        const SizedBox(height: 24),
        
        // Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final selectedTime = _getSelectedTime();
                    widget.onSaved(selectedTime);
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
