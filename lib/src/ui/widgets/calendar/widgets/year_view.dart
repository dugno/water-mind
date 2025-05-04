import 'package:flutter/material.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_day.dart';
import 'day_view.dart';

/// Widget hiển thị chế độ xem năm của lịch
class YearView extends StatefulWidget {
  /// Controller quản lý lịch
  final CalendarController controller;

  /// Constructor
  const YearView({
    super.key,
    required this.controller,
  });

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  // Danh sách các năm để chọn (từ năm hiện tại - 10 đến năm hiện tại + 10)
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    _initAvailableYears();
  }

  void _initAvailableYears() {
    final currentYear = DateTime.now().year;
    _availableYears = List.generate(21, (index) => currentYear - 10 + index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown để chọn năm
        _buildYearSelector(),

        // Danh sách 12 tháng trong năm
        Expanded(
          child: _buildMonthsList(),
        ),
      ],
    );
  }

  Widget _buildYearSelector() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: widget.controller.currentYear.year,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
          iconEnabledColor: Theme.of(context).colorScheme.primary,
          items: _availableYears.map((year) {
            final isCurrentYear = year == DateTime.now().year;
            final isSelected = year == widget.controller.currentYear.year;

            return DropdownMenuItem<int>(
              value: year,
              child: Center(
                child: Text(
                  'Năm $year',
                  style: TextStyle(
                    fontWeight: isCurrentYear || isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isCurrentYear
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                            : null,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (int? year) {
            if (year != null) {
              setState(() {
                widget.controller.goToYear(DateTime(year, 1, 1));
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthsList() {
    final months = widget.controller.getMonthsInCurrentYear();

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        return _buildMonthCell(context, month);
      },
    );
  }

  Widget _buildMonthCell(BuildContext context, DateTime month) {
    final locale = widget.controller.config.locale ?? Localizations.localeOf(context);
    final monthName = widget.controller.getMonthName(month, locale);
    final isCurrentMonth = month.year == DateTime.now().year &&
                          month.month == DateTime.now().month;
    // Lấy danh sách ngày trong tháng
    final days = _getDaysInMonth(month);

    // Lấy danh sách tên các ngày trong tuần
    final weekdayNames = widget.controller.getWeekdayNames(locale, short: true);

    return Container(
      margin: const EdgeInsets.all(8.0),
      height: 300, // Chiều cao cố định cho mỗi tháng
      child: InkWell(
        onTap: () {
          widget.controller.goToMonth(month);
          widget.controller.setViewMode(CalendarViewMode.month);
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tên tháng
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Text(
                  monthName,
                  style: widget.controller.config.monthTextStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCurrentMonth
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.titleMedium?.color,
                          ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Header hiển thị tên các ngày trong tuần
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekdayNames.map((name) => Text(
                    name,
                    style: widget.controller.config.weekdayTextStyle ??
                        TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 4),

              // Lưới ngày trong tháng
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.3,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                  ),
                  itemCount: _calculateGridItemCount(month, days),
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
          ),
        ),
      ),
    );
  }

  /// Tính toán số ô cần thiết cho grid
  int _calculateGridItemCount(DateTime month, List<CalendarDay> days) {
    // Tính số hàng cần thiết (tối đa 6 hàng)
    final int startOffset = _calculateStartOffset(month);
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
    if (widget.controller.config.firstDayOfWeek == 1) { // Thứ hai
      return weekday == 0 ? 6 : weekday - 1;
    } else { // Chủ nhật
      return weekday;
    }
  }

  Widget _buildDayCell(CalendarDay day) {
    // Sử dụng DayView nhưng điều chỉnh kích thước phù hợp với year_view
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: DayView(
        day: day,
        config: widget.controller.config,
        onTap: () => widget.controller.selectDay(day.date),
      ),
    );
  }

  List<CalendarDay> _getDaysInMonth(DateTime month) {
    final List<CalendarDay> days = [];

    // Ngày đầu tiên và cuối cùng của tháng
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Ngày hiện tại để kiểm tra "hôm nay"
    final today = DateTime.now();

    // Tạo danh sách các ngày trong tháng
    DateTime currentDay = firstDay;
    while (!currentDay.isAfter(lastDay)) {
      days.add(CalendarDay(
        date: currentDay,
        isCurrentMonth: true,
        isToday: currentDay.year == today.year &&
                currentDay.month == today.month &&
                currentDay.day == today.day,
        isWeekend: currentDay.weekday == DateTime.saturday ||
                  currentDay.weekday == DateTime.sunday,
        isSelected: widget.controller.selectedDay != null &&
                  currentDay.year == widget.controller.selectedDay!.year &&
                  currentDay.month == widget.controller.selectedDay!.month &&
                  currentDay.day == widget.controller.selectedDay!.day,
      ));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return days;
  }
}
