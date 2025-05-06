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
    final weekdayNames = _getCustomWeekdayNames(week);

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
          height: 50, // Chiều cao cố định
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



  // Lấy danh sách tên các ngày trong tuần theo định dạng "Th 2", "Th 3", v.v.
  List<String> _getCustomWeekdayNames(DateTime week) {
    final List<String> names = [];
    final days = controller.getDaysInWeek(week);

    for (final day in days) {
      final weekday = day.date.weekday;

      // Tạo tên ngày theo định dạng "Th 2", "Th 3", v.v.
      String name;
      if (weekday == 7) {
        name = 'CN'; // Chủ nhật
      } else {
        name = 'Th $weekday'; // Thứ 2, Thứ 3, v.v.
      }

      names.add(name);
    }

    return names;
  }
}
