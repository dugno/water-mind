import 'package:flutter/material.dart';
import '../models/calendar_config.dart';
import '../models/calendar_day.dart';
import '../utils/dashed_border_painter.dart';


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

    // Xác định màu đường viền
    final borderColor = isSelected
        ? (config.selectedDayTextColor ?? Theme.of(context).colorScheme.primary)
        : config.dashedBorderColor ?? Colors.grey.withOpacity(0.5);

    // Xác định màu tiến trình
    final progressColor = config.progressColor ?? Theme.of(context).colorScheme.primary;

    // Tạo widget hiển thị ngày
    Widget dayWidget;

    // Hiển thị tên ngày trong tuần ở trên và số ngày trong vòng tròn
    dayWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Vòng tròn chỉ chứa số ngày
        _buildDayCircle(context, borderColor, backgroundColor, textColor, progressColor),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: dayWidget,
      ),
    );
  }

  /// Xây dựng vòng tròn hiển thị ngày
  Widget _buildDayCircle(
    BuildContext context,
    Color borderColor,
    Color? backgroundColor,
    Color? textColor,
    Color progressColor,
  ) {
    final circleSize = config.dayCircleSize;
    final useDashedBorders = config.useDashedBorders;

    // Nội dung bên trong vòng tròn luôn là số ngày
    Widget content = Text(
      day.date.day.toString().padLeft(2, '0'),
      style: config.dayTextStyle ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: (day.isToday || day.isSelected) ? FontWeight.bold : null,
              ),
    );

    // Tạo container cho vòng tròn
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: useDashedBorders
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            )
          : BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: config.dashedBorderWidth,
              ),
            ),
      child: Stack(
        children: [
          // Đường viền đứt nét nếu được cấu hình
          if (useDashedBorders)
            CustomPaint(
              size: Size(circleSize, circleSize),
              painter: DashedBorderPainter(
                color: borderColor,
                strokeWidth: config.dashedBorderWidth,
                dashLength: config.dashedBorderDashLength,
                gapLength: config.dashedBorderGapLength,
              ),
            ),

          // Hiển thị tiến trình nếu có
          if (day.hasProgress)
            CircularProgressIndicator(
              value: day.progress,
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              backgroundColor: Colors.transparent,
            ),

          // Nội dung (số ngày)
          Center(child: content),
        ],
      ),
    );
  }


}
