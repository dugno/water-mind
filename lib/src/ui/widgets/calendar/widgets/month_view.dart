import 'package:flutter/material.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_day.dart';
import 'day_view.dart';

/// Widget hiển thị chế độ xem tháng của lịch
class MonthView extends StatelessWidget {
  /// Controller quản lý lịch
  final CalendarController controller;

  /// Constructor
  const MonthView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.monthPageController,
      onPageChanged: (index) {
        final month = controller.getMonthFromOffset(index);
        controller.goToMonth(month);
      },
      itemBuilder: (context, index) {
        final month = controller.getMonthFromOffset(index);
        return _buildMonthPage(context, month);
      },
    );
  }

  Widget _buildMonthPage(BuildContext context, DateTime month) {
    // Lấy danh sách ngày trong tháng (chỉ ngày trong tháng)
    final days = controller.getDaysInCurrentMonth();

    // Lấy danh sách tên các ngày trong tuần
    final locale = controller.config.locale ?? Localizations.localeOf(context);
    final weekdayNames = controller.getWeekdayNames(locale, short: true);

    return Column(
      children: [
        // Header hiển thị tên các ngày trong tuần
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              if (controller.config.showWeekNumbers)
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      '#',
                      style: controller.config.weekdayTextStyle ??
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
              ...weekdayNames.map((name) => Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        name,
                        style: controller.config.weekdayTextStyle ??
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // Grid hiển thị các ngày trong tháng
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.3,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ),
            itemCount: _calculateGridItemCount(days),
            itemBuilder: (context, index) {
              // Tính toán vị trí của ngày trong grid
              final int startOffset = _calculateStartOffset(month);

              // Nếu index nhỏ hơn offset, hiển thị ô trống
              if (index < startOffset) {
                return const SizedBox.shrink();
              }

              // Nếu index lớn hơn số ngày + offset, hiển thị ô trống
              final dayIndex = index - startOffset;
              if (dayIndex >= days.length) {
                return const SizedBox.shrink();
              }

              // Hiển thị ngày
              return _buildDayCell(days[dayIndex]);
            },
          ),
        ),
      ],
    );
  }

  /// Tính toán số ô cần thiết cho grid
  int _calculateGridItemCount(List<CalendarDay> days) {
    // Tính số hàng cần thiết (tối đa 6 hàng)
    final int startOffset = _calculateStartOffset(controller.currentMonth);
    final int totalCells = startOffset + days.length;
    final int rows = (totalCells / 7).ceil();

    // Trả về tổng số ô (7 cột x số hàng)
    return rows * 7;
  }

  /// Tính toán offset cho ngày đầu tiên của tháng
  int _calculateStartOffset(DateTime month) {
    // Lấy ngày đầu tiên của tháng
    final firstDay = DateTime(month.year, month.month, 1);

    // Lấy thứ của ngày đầu tiên (0 = Chủ nhật, 6 = Thứ bảy)
    int weekday = firstDay.weekday % 7;

    // Điều chỉnh theo ngày bắt đầu tuần
    if (controller.config.firstDayOfWeek == 1) { // Thứ hai
      return weekday == 0 ? 6 : weekday - 1;
    } else { // Chủ nhật
      return weekday;
    }
  }

  Widget _buildDayCell(CalendarDay day) {
    return DayView(
      day: day,
      config: controller.config,

      onTap: () => controller.selectDay(day.date),
    );
  }
}
