import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';

class BornSegment extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? initialDate;

  const BornSegment({
    super.key,
    this.onDateSelected,
    this.initialDate,
  });

  @override
  State<BornSegment> createState() => _BornSegmentState();
}

class _BornSegmentState extends State<BornSegment> with HapticFeedbackMixin {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  // Controllers for wheel pickers
  late WheelPickerController _daysController;
  late WheelPickerController _monthsController;
  late WheelPickerController _yearsController;

  @override
  void initState() {
    super.initState();

    // Initialize with provided date or default to 18 years ago
    final initialDate = widget.initialDate ??
        DateTime.now().subtract(const Duration(days: 365 * 18));

    _selectedDay = initialDate.day;
    _selectedMonth = initialDate.month;
    _selectedYear = initialDate.year;

    // Initialize controllers
    final currentYear = DateTime.now().year;

    _daysController = WheelPickerController(
      itemCount: 31,
      initialIndex: _selectedDay - 1,
    );

    _monthsController = WheelPickerController(
      itemCount: 12,
      initialIndex: _selectedMonth - 1,
    );

    _yearsController = WheelPickerController(
      itemCount: 100,
      initialIndex: currentYear - _selectedYear,
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    try {
      _daysController.dispose();
      _monthsController.dispose();
      _yearsController.dispose();
    } catch (e) {
      // Bỏ qua lỗi khi dispose controller
      debugPrint('Error disposing born segment controllers: $e');
    }
    super.dispose();
  }

  void _validateDate() {
    // Get the last day of the selected month
    final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    // If the selected day is greater than the last day of the month, adjust it
    if (_selectedDay > lastDayOfMonth) {
      _selectedDay = lastDayOfMonth;
    }
  }

  DateTime _getCurrentDate() {
    return DateTime(_selectedYear, _selectedMonth, _selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
          ),
          child: _buildDatePicker(),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    // Months column (1-12)
    final List<String> monthNames = [
      context.l10n.january,
      context.l10n.february,
      context.l10n.march,
      context.l10n.april,
      context.l10n.may,
      context.l10n.june,
      context.l10n.july,
      context.l10n.august,
      context.l10n.september,
      context.l10n.october,
      context.l10n.november,
      context.l10n.december
    ];

    // Current year
    final currentYear = DateTime.now().year;

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Days wheel
          Expanded(
            child: WheelPicker(
              builder: (context, index) {
                final value = index + 1;
                final isSelected = value == _selectedDay;

                return Text(
                  '$value',
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColor.thirdColor // Blue color for selected item
                        : Colors.white70,   // Light color for better visibility on dark background
                  ),
                );
              },
              controller: _daysController,
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
                  _selectedDay = index + 1;
                });
                _validateDate();
                if (widget.onDateSelected != null) {
                  widget.onDateSelected!(_getCurrentDate());
                }
              },
            ),
          ),

          // Months wheel
          Expanded(
            child: WheelPicker(
              builder: (context, index) {
                final isSelected = (index + 1) == _selectedMonth;

                return Text(
                  monthNames[index],
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColor.thirdColor // Blue color for selected item
                        : Colors.white70,   // Light color for better visibility on dark background
                  ),
                );
              },
              controller: _monthsController,
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
                  _selectedMonth = index + 1;
                });
                _validateDate();
                if (widget.onDateSelected != null) {
                  widget.onDateSelected!(_getCurrentDate());
                }
              },
            ),
          ),

          // Years wheel
          Expanded(
            child: WheelPicker(
              builder: (context, index) {
                final value = currentYear - index;
                final isSelected = value == _selectedYear;

                return Text(
                  '$value',
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 20,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColor.thirdColor // Blue color for selected item
                        : Colors.white70,   // Light color for better visibility on dark background
                  ),
                );
              },
              controller: _yearsController,
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
                  _selectedYear = currentYear - index;
                });
                _validateDate();
                if (widget.onDateSelected != null) {
                  widget.onDateSelected!(_getCurrentDate());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
