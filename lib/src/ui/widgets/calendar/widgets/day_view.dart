import 'package:flutter/material.dart';
import '../models/calendar_config.dart';
import '../models/calendar_day.dart';


/// Widget hiển thị một ngày trong lịch
class DayView extends StatelessWidget {
  /// Ngày cần hiển thị
  final CalendarDay day;

  /// Cấu hình lịch
  final CalendarConfig config;

  /// Callback khi ngày được nhấp
  final VoidCallback? onTap;

  /// Constructor
  const DayView({
    super.key,
    required this.day,
    required this.config,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday && config.highlightToday;
    final isCurrentMonth = day.isCurrentMonth;
    final isSelected = day.isSelected;
    final isWeekend = day.isWeekend;

    // Xác định màu nền
    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = config.selectedDayBackgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.2);
    } else if (isToday) {
      backgroundColor = config.todayHighlightColor ?? Theme.of(context).colorScheme.primaryContainer;
    } else if (isWeekend && config.weekendBackgroundColor != null) {
      backgroundColor = config.weekendBackgroundColor;
    }

    // Xác định màu chữ
    Color? textColor;
    if (isSelected) {
      textColor = config.selectedDayTextColor ?? Theme.of(context).colorScheme.primary;
    } else if (!isCurrentMonth) {
      textColor = Colors.grey;
    } else if (isWeekend) {
      textColor = config.weekendTextColor ?? Colors.red;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isSelected
                ? (config.selectedDayTextColor ?? Theme.of(context).colorScheme.primary)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.0 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Số ngày
            Text(
              day.date.day.toString(),
              style: config.dayTextStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: (isToday || isSelected) ? FontWeight.bold : null,
                      ),
            ),


          ],
        ),
      ),
    );
  }
}
