import 'package:flutter/material.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_config.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/models/wheel_picker_item.dart';
import 'package:water_mind/src/ui/widgets/wheel_picker/widgets/wheel_picker.dart';

/// Bottom sheet for setting wake up and bed time
class TimeSettingsBottomSheet extends StatefulWidget {
  /// Initial wake up time
  final TimeOfDay? initialWakeUpTime;
  
  /// Initial bed time
  final TimeOfDay? initialBedTime;
  
  /// Callback when times are saved
  final Function(TimeOfDay wakeUpTime, TimeOfDay bedTime) onSaved;

  /// Constructor
  const TimeSettingsBottomSheet({
    super.key,
    this.initialWakeUpTime,
    this.initialBedTime,
    required this.onSaved,
  });

  /// Show the time settings bottom sheet
  static Future<void> show({
    required BuildContext context,
    TimeOfDay? initialWakeUpTime,
    TimeOfDay? initialBedTime,
    required Function(TimeOfDay wakeUpTime, TimeOfDay bedTime) onSaved,
  }) {
    return BaseBottomSheet.show(
      context: context,
      backgroundColor: AppColor.thirdColor,
      maxHeightFactor: 0.8,
      child: TimeSettingsBottomSheet(
        initialWakeUpTime: initialWakeUpTime,
        initialBedTime: initialBedTime,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<TimeSettingsBottomSheet> createState() => _TimeSettingsBottomSheetState();
}

class _TimeSettingsBottomSheetState extends State<TimeSettingsBottomSheet> with HapticFeedbackMixin {
  late TimeOfDay _wakeUpTime;
  late TimeOfDay _bedTime;
  bool _isWakeUpTimeSelected = true;

  @override
  void initState() {
    super.initState();
    _wakeUpTime = widget.initialWakeUpTime ?? const TimeOfDay(hour: 7, minute: 0);
    _bedTime = widget.initialBedTime ?? const TimeOfDay(hour: 23, minute: 0);
  }

  Widget _buildTimePicker() {
    final selectedTime = _isWakeUpTimeSelected ? _wakeUpTime : _bedTime;
    
    // Create hours items (0-23)
    final List<WheelPickerItem<int>> hoursItems = List.generate(
      24,
      (index) => WheelPickerItem<int>(
        value: index,
        text: index.toString().padLeft(2, '0'),
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
    
    return Column(
      children: [
        // Time display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Time picker
        SizedBox(
          height: 200,
          child: WheelPicker(
            columns: [hoursItems, minutesItems],
            initialIndices: [selectedTime.hour, selectedTime.minute],
            onSelectedItemChanged: (columnIndex, itemIndex, value) {
              haptic(HapticFeedbackType.selection);
              setState(() {
                if (columnIndex == 0) {
                  // Hour changed
                  if (_isWakeUpTimeSelected) {
                    _wakeUpTime = TimeOfDay(hour: value as int, minute: _wakeUpTime.minute);
                  } else {
                    _bedTime = TimeOfDay(hour: value as int, minute: _bedTime.minute);
                  }
                } else {
                  // Minute changed
                  if (_isWakeUpTimeSelected) {
                    _wakeUpTime = TimeOfDay(hour: _wakeUpTime.hour, minute: value as int);
                  } else {
                    _bedTime = TimeOfDay(hour: _bedTime.hour, minute: value as int);
                  }
                }
              });
            },
            config: const WheelPickerConfig(
              height: 200,
              useHapticFeedback: true,
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
            context.l10n.timeSettings,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Time type selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: true,
                label: Text(context.l10n.wakeUpTime),
                icon: const Icon(Icons.wb_sunny_outlined),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text(context.l10n.bedTime),
                icon: const Icon(Icons.nightlight_outlined),
              ),
            ],
            selected: {_isWakeUpTimeSelected},
            onSelectionChanged: (Set<bool> selection) {
              if (selection.isNotEmpty) {
                haptic(HapticFeedbackType.selection);
                setState(() {
                  _isWakeUpTimeSelected = selection.first;
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
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
                    widget.onSaved(_wakeUpTime, _bedTime);
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
