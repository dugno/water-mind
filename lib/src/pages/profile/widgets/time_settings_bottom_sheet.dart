import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/base_bottom_sheet.dart';

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
      useGradientBackground: true,
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

    // Create controllers
    final hoursController = WheelPickerController(
      itemCount: 24,
      initialIndex: selectedTime.hour,
    );

    final minutesController = WheelPickerController(
      itemCount: 60,
      initialIndex: selectedTime.minute,
    );

    return Column(
      children: [
        // Time display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColor.thirdColor.withAlpha(77), // Light blue with 0.3 opacity
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Time picker
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26), // 0.1 opacity
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                // Hours wheel
                Expanded(
                  child: WheelPicker(
                    builder: (context, index) {
                      final value = index;
                      final isSelected = value == selectedTime.hour;

                      return Text(
                        value.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 22 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColor.thirdColor // Blue color for selected item
                              : Colors.white70, // Light color for better visibility on dark background
                        ),
                      );
                    },
                    controller: hoursController,
                    selectedIndexColor: Colors.transparent,
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
                        if (_isWakeUpTimeSelected) {
                          _wakeUpTime = TimeOfDay(hour: index, minute: _wakeUpTime.minute);
                        } else {
                          _bedTime = TimeOfDay(hour: index, minute: _bedTime.minute);
                        }
                      });
                    },
                  ),
                ),

                // Separator
                const Text(
                  ":",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColor.thirdColor,
                  ),
                ),

                // Minutes wheel
                Expanded(
                  child: WheelPicker(
                    builder: (context, index) {
                      final value = index;
                      final isSelected = value == selectedTime.minute;

                      return Text(
                        value.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: isSelected ? 22 : 20,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColor.thirdColor // Blue color for selected item
                              : Colors.white70, // Light color for better visibility on dark background
                        ),
                      );
                    },
                    controller: minutesController,
                    selectedIndexColor: Colors.transparent,
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
                        if (_isWakeUpTimeSelected) {
                          _wakeUpTime = TimeOfDay(hour: _wakeUpTime.hour, minute: index);
                        } else {
                          _bedTime = TimeOfDay(hour: _bedTime.hour, minute: index);
                        }
                      });
                    },
                  ),
                ),
              ],
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Time type selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26), // 0.1 opacity
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  // Wake Up Time button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isWakeUpTimeSelected) {
                          haptic(HapticFeedbackType.selection);
                          setState(() {
                            _isWakeUpTimeSelected = true;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: _isWakeUpTimeSelected
                              ? AppColor.thirdColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.wakeUpTime,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: _isWakeUpTimeSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bed Time button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isWakeUpTimeSelected) {
                          haptic(HapticFeedbackType.selection);
                          setState(() {
                            _isWakeUpTimeSelected = false;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: !_isWakeUpTimeSelected
                              ? AppColor.thirdColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.nightlight_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.bedTime,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: !_isWakeUpTimeSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Time picker
        _buildTimePicker(),

        const SizedBox(height: 16),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              haptic(HapticFeedbackType.success);
              widget.onSaved(_wakeUpTime, _bedTime);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.thirdColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.l10n.save),
          ),
        ),
      ],
    );
  }
}
