import 'package:flutter/material.dart';
import '../controllers/calendar_controller.dart';


import 'day_view.dart';

/// Widget hiển thị chế độ xem tuần của lịch
class WeekView extends StatelessWidget {
  /// Controller quản lý lịch
  final CalendarController controller;

  /// Constructor
  const WeekView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.weekPageController,
      onPageChanged: (index) {
        final week = controller.getWeekFromOffset(index);
        controller.goToWeek(week);
      },
      itemBuilder: (context, index) {
        final week = controller.getWeekFromOffset(index);
        return _buildWeekPage(context, week);
      },
    );
  }

  Widget _buildWeekPage(BuildContext context, DateTime week) {
    // Lấy danh sách ngày trong tuần
    final days = controller.getDaysInWeek(week);

    // Lấy danh sách tên các ngày trong tuần
    final locale = controller.config.locale ?? Localizations.localeOf(context);
    final weekdayNames = controller.getWeekdayNames(locale, short: true);

    return Column(
      children: [
        // Header hiển thị tên các ngày trong tuần
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: weekdayNames
                .map((name) => Expanded(
                      child: Center(
                        child: Text(
                          name,
                          style: controller.config.weekdayTextStyle ??
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        // Hàng hiển thị các ngày trong tuần
        SizedBox(
          height: 60,
          child: Row(
            children: days
                .map((day) => Expanded(
                      child: DayView(
                        day: day,
                        config: controller.config,
                        onTap: () => controller.selectDay(day.date),
                      ),
                    ))
                .toList(),
          ),
        ),

      ],
    );
  }



  // Lấy danh sách tên các ngày trong tuần
  List<String> get weekdayNames {
    final locale = controller.config.locale ?? const Locale('vi');
    return controller.getWeekdayNames(locale, short: true);
  }
}
