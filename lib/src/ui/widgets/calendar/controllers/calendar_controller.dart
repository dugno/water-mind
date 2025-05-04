import 'package:flutter/material.dart';
import '../models/calendar_config.dart';
import '../models/calendar_day.dart';

import '../utils/date_utils.dart';

/// Enum định nghĩa các chế độ xem của lịch
enum CalendarViewMode {
  /// Chế độ xem năm
  year,

  /// Chế độ xem tháng
  month,

  /// Chế độ xem tuần
  week,
}

/// Controller quản lý trạng thái và logic của calendar
class CalendarController extends ChangeNotifier {
  /// Cấu hình calendar
  CalendarConfig _config;

  /// Năm hiện tại đang hiển thị
  late DateTime _currentYear;

  /// Tháng hiện tại đang hiển thị
  DateTime _currentMonth;

  /// Tuần hiện tại đang hiển thị (ngày đầu tiên của tuần)
 late DateTime _currentWeek;

  /// Ngày được chọn
  DateTime? _selectedDay;



  /// Chế độ xem hiện tại
  CalendarViewMode _viewMode;

  /// Page controller cho chế độ xem tháng
  final PageController monthPageController;

  /// Page controller cho chế độ xem tuần
  final PageController weekPageController;

  /// Constructor
  CalendarController({
    CalendarConfig? config,
    DateTime? initialYear,
    DateTime? initialMonth,
    DateTime? initialWeek,
    DateTime? selectedDay,
    CalendarViewMode initialViewMode = CalendarViewMode.month,
  }) :
    _config = config ?? const CalendarConfig(),
    _currentMonth = initialMonth ?? DateTime.now(),
    _selectedDay = selectedDay,
    _viewMode = initialViewMode,
    monthPageController = PageController(initialPage: 500), // Bắt đầu từ giữa để có thể scroll cả 2 hướng
    weekPageController = PageController(initialPage: 500) {

    // Khởi tạo năm hiện tại
    _currentYear = initialYear ?? DateTime(_currentMonth.year, 1, 1);

    // Khởi tạo tuần hiện tại
    _currentWeek = initialWeek ??
        CalendarDateUtils.firstDayOfWeek(
          _selectedDay ?? DateTime.now(),
          _config.firstDayOfWeek
        );

    // Chuẩn hóa tháng hiện tại (ngày 1 của tháng)
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);

    // Chuẩn hóa năm hiện tại (ngày 1 tháng 1)
    _currentYear = DateTime(_currentYear.year, 1, 1);
  }

  /// Getter cho config
  CalendarConfig get config => _config;

  /// Cập nhật config
  set config(CalendarConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  /// Getter cho năm hiện tại
  DateTime get currentYear => _currentYear;

  /// Getter cho tháng hiện tại
  DateTime get currentMonth => _currentMonth;

  /// Getter cho tuần hiện tại
  DateTime get currentWeek => _currentWeek;

  /// Getter cho ngày được chọn
  DateTime? get selectedDay => _selectedDay;

  /// Getter cho chế độ xem hiện tại
  CalendarViewMode get viewMode => _viewMode;

  /// Chuyển đổi chế độ xem
  void setViewMode(CalendarViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  /// Chọn một ngày
  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  /// Chuyển đến tháng cụ thể
  void goToMonth(DateTime month) {
    final normalizedMonth = DateTime(month.year, month.month, 1);
    if (normalizedMonth.year != _currentMonth.year ||
        normalizedMonth.month != _currentMonth.month) {
      _currentMonth = normalizedMonth;
      notifyListeners();
    }
  }

  /// Chuyển đến tuần cụ thể
  void goToWeek(DateTime week) {
    final firstDayOfWeek = CalendarDateUtils.firstDayOfWeek(
      week,
      _config.firstDayOfWeek
    );

    if (!CalendarDateUtils.isSameDay(firstDayOfWeek, _currentWeek)) {
      _currentWeek = firstDayOfWeek;

      // Cập nhật tháng hiện tại nếu tuần mới thuộc tháng khác
      if (firstDayOfWeek.month != _currentMonth.month ||
          firstDayOfWeek.year != _currentMonth.year) {
        _currentMonth = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, 1);
      }

      notifyListeners();
    }
  }

  /// Chuyển đến tuần chứa ngày hôm nay
  void goToToday() {
    final today = DateTime.now();
    selectDay(today);

    if (_viewMode == CalendarViewMode.week) {
      goToWeek(today);
    } else if (_viewMode == CalendarViewMode.month) {
      goToMonth(today);
    } else {
      goToYear(today);
    }
  }

  /// Chuyển đến năm cụ thể
  void goToYear(DateTime year) {
    final normalizedYear = DateTime(year.year, 1, 1);
    if (normalizedYear.year != _currentYear.year) {
      _currentYear = normalizedYear;
      notifyListeners();
    }
  }

  /// Chuyển đến năm tiếp theo
  void nextYear() {
    goToYear(DateTime(_currentYear.year + 1, 1, 1));
  }

  /// Chuyển đến năm trước
  void previousYear() {
    goToYear(DateTime(_currentYear.year - 1, 1, 1));
  }

  /// Chuyển đến tháng tiếp theo
  void nextMonth() {
    goToMonth(DateTime(_currentMonth.year, _currentMonth.month + 1, 1));
  }

  /// Chuyển đến tháng trước
  void previousMonth() {
    goToMonth(DateTime(_currentMonth.year, _currentMonth.month - 1, 1));
  }

  /// Chuyển đến tuần tiếp theo
  void nextWeek() {
    goToWeek(_currentWeek.add(const Duration(days: 7)));
  }

  /// Chuyển đến tuần trước
  void previousWeek() {
    goToWeek(_currentWeek.subtract(const Duration(days: 7)));
  }

  /// Lấy danh sách tháng trong năm hiện tại
  List<DateTime> getMonthsInCurrentYear() {
    final List<DateTime> months = [];

    for (int month = 1; month <= 12; month++) {
      months.add(DateTime(_currentYear.year, month, 1));
    }

    return months;
  }

  /// Lấy danh sách ngày trong tháng hiện tại (chỉ ngày trong tháng)
  List<CalendarDay> getDaysInCurrentMonth() {
    final List<CalendarDay> days = [];

    // Ngày đầu tiên và cuối cùng của tháng
    final firstDay = CalendarDateUtils.firstDayOfMonth(_currentMonth);
    final lastDay = CalendarDateUtils.lastDayOfMonth(_currentMonth);

    // Ngày hiện tại để kiểm tra "hôm nay"
    final today = DateTime.now();

    // Tạo danh sách các ngày trong tháng
    DateTime currentDay = firstDay;
    while (!currentDay.isAfter(lastDay)) {
      days.add(CalendarDay(
        date: currentDay,
        isCurrentMonth: true,
        isToday: CalendarDateUtils.isSameDay(currentDay, today),
        isWeekend: CalendarDateUtils.isWeekend(currentDay),
        isSelected: _selectedDay != null &&
            CalendarDateUtils.isSameDay(currentDay, _selectedDay!),
      ));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return days;
  }

  /// Lấy danh sách ngày trong tuần hiện tại
  List<CalendarDay> getDaysInCurrentWeek() {
    final List<CalendarDay> days = [];

    // Ngày hiện tại để kiểm tra "hôm nay"
    final today = DateTime.now();

    // Tạo danh sách các ngày trong tuần
    DateTime currentDay = _currentWeek;
    for (int i = 0; i < 7; i++) {
      days.add(CalendarDay(
        date: currentDay,
        isCurrentMonth: currentDay.month == _currentMonth.month,
        isToday: CalendarDateUtils.isSameDay(currentDay, today),
        isWeekend: CalendarDateUtils.isWeekend(currentDay),
        isSelected: _selectedDay != null &&
            CalendarDateUtils.isSameDay(currentDay, _selectedDay!),
      ));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return days;
  }

  /// Lấy danh sách ngày cho tuần cụ thể
  List<CalendarDay> getDaysInWeek(DateTime week) {
    final firstDayOfWeek = CalendarDateUtils.firstDayOfWeek(
      week,
      _config.firstDayOfWeek
    );

    final List<CalendarDay> days = [];

    // Ngày hiện tại để kiểm tra "hôm nay"
    final today = DateTime.now();

    // Tạo danh sách các ngày trong tuần
    DateTime currentDay = firstDayOfWeek;
    for (int i = 0; i < 7; i++) {
      days.add(CalendarDay(
        date: currentDay,
        isCurrentMonth: currentDay.month == _currentMonth.month,
        isToday: CalendarDateUtils.isSameDay(currentDay, today),
        isWeekend: CalendarDateUtils.isWeekend(currentDay),
        isSelected: _selectedDay != null &&
            CalendarDateUtils.isSameDay(currentDay, _selectedDay!),
      ));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return days;
  }



  /// Lấy danh sách tên các ngày trong tuần theo thứ tự
  List<String> getWeekdayNames(Locale locale, {bool short = false}) {
    final orderedWeekdays = CalendarDateUtils.getOrderedWeekdays(_config.firstDayOfWeek);

    return orderedWeekdays.map((weekday) {
      return CalendarDateUtils.getWeekdayName(weekday, locale, short: short);
    }).toList();
  }

  /// Lấy tên tháng
  String getMonthName(DateTime month, Locale locale) {
    return CalendarDateUtils.getMonthName(month, locale);
  }

  /// Tính toán offset cho PageView
  int getWeekOffset(DateTime week) {
    final baseWeek = CalendarDateUtils.firstDayOfWeek(
      DateTime.now(),
      _config.firstDayOfWeek
    );

    final firstDayOfTargetWeek = CalendarDateUtils.firstDayOfWeek(
      week,
      _config.firstDayOfWeek
    );

    // Tính số tuần chênh lệch
    final difference = firstDayOfTargetWeek.difference(baseWeek).inDays;
    return 500 + (difference ~/ 7); // 500 là trang giữa
  }



  /// Tính toán offset cho PageView tháng
  int getMonthOffset(DateTime month) {
    final baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    // Tính số tháng chênh lệch
    final monthsDifference =
        (month.year - baseMonth.year) * 12 +
        (month.month - baseMonth.month);

    return 500 + monthsDifference; // 500 là trang giữa
  }



  /// Lấy tháng từ offset
  DateTime getMonthFromOffset(int offset) {
    final baseMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final monthsDifference = offset - 500;

    return DateTime(
      baseMonth.year + (baseMonth.month + monthsDifference - 1) ~/ 12,
      (baseMonth.month + monthsDifference - 1) % 12 + 1,
      1
    );
  }

  /// Lấy tuần từ offset
  DateTime getWeekFromOffset(int offset) {
    final baseWeek = CalendarDateUtils.firstDayOfWeek(
      DateTime.now(),
      _config.firstDayOfWeek
    );

    final weeksDifference = offset - 500;
    return baseWeek.add(Duration(days: weeksDifference * 7));
  }

  @override
  void dispose() {
    monthPageController.dispose();
    weekPageController.dispose();
    super.dispose();
  }
}
