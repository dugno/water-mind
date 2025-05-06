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

  /// Map lưu trữ tiến trình cho các ngày
  final Map<String, double> _progressMap = {};


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
    DateTime? initialDate,
    CalendarViewMode initialViewMode = CalendarViewMode.month,
  }) :
    _config = config ?? const CalendarConfig(),
    _currentMonth = initialMonth ?? DateTime.now(),
    _selectedDay = selectedDay ?? initialDate,
    _viewMode = initialViewMode,
    monthPageController = PageController(initialPage: 500), // Bắt đầu từ giữa để có thể scroll cả 2 hướng
    weekPageController = PageController(initialPage: 500) {

    // Sử dụng initialDate nếu được cung cấp
    final effectiveDate = initialDate ?? DateTime.now();

    // Khởi tạo năm hiện tại
    _currentYear = initialYear ?? DateTime(effectiveDate.year, 1, 1);

    // Khởi tạo tuần hiện tại
    _currentWeek = initialWeek ??
        CalendarDateUtils.firstDayOfWeek(
          _selectedDay ?? effectiveDate,
          _config.firstDayOfWeek
        );

    // Chuẩn hóa tháng hiện tại (ngày 1 của tháng)
    _currentMonth = initialMonth != null
        ? DateTime(initialMonth.year, initialMonth.month, 1)
        : DateTime(effectiveDate.year, effectiveDate.month, 1);

    // Chuẩn hóa năm hiện tại (ngày 1 tháng 1)
    _currentYear = DateTime(_currentYear.year, 1, 1);

    // Thiết lập các page controller để hiển thị đúng tháng và tuần
    if (initialDate != null) {
      // Tính toán offset cho PageView tháng và tuần
      final monthOffset = getMonthOffset(_currentMonth);
      final weekOffset = getWeekOffset(_currentWeek);

      // Thiết lập trang ban đầu cho các PageController
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (monthPageController.hasClients) {
          monthPageController.jumpToPage(monthOffset);
        }

        if (weekPageController.hasClients) {
          weekPageController.jumpToPage(weekOffset);
        }
      });
    }
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

  /// Cập nhật ngày hiện tại và các giá trị liên quan
  void updateCurrentDate(DateTime date) {
    // Cập nhật ngày được chọn
    _selectedDay = date;

    // Cập nhật tuần hiện tại
    final newWeek = CalendarDateUtils.firstDayOfWeek(date, _config.firstDayOfWeek);
    if (!CalendarDateUtils.isSameDay(newWeek, _currentWeek)) {
      _currentWeek = newWeek;

      // Cập nhật PageController cho tuần
      final weekOffset = getWeekOffset(newWeek);
      if (weekPageController.hasClients) {
        weekPageController.jumpToPage(weekOffset);
      }
    }

    // Cập nhật tháng hiện tại nếu cần
    final newMonth = DateTime(date.year, date.month, 1);
    if (newMonth.month != _currentMonth.month || newMonth.year != _currentMonth.year) {
      _currentMonth = newMonth;

      // Cập nhật PageController cho tháng
      final monthOffset = getMonthOffset(newMonth);
      if (monthPageController.hasClients) {
        monthPageController.jumpToPage(monthOffset);
      }
    }

    // Cập nhật năm hiện tại nếu cần
    final newYear = DateTime(date.year, 1, 1);
    if (newYear.year != _currentYear.year) {
      _currentYear = newYear;
    }

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
    updateCurrentDate(today);
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
        progress: getProgressForDay(currentDay),
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
        progress: getProgressForDay(currentDay),
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
        progress: getProgressForDay(currentDay),
      ));
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return days;
  }

  /// Lấy giá trị tiến trình cho một ngày cụ thể
  /// Trả về giá trị từ 0.0 đến 1.0
  double getProgressForDay(DateTime day) {
    // Tạo key từ ngày (yyyy-MM-dd)
    final key = _formatDateKey(day);

    // Trả về giá trị tiến trình nếu có, nếu không trả về 0.0
    return _progressMap[key] ?? 0.0;
  }

  /// Cập nhật tiến trình cho một ngày cụ thể
  /// progress: giá trị từ 0.0 đến 1.0
  void updateProgressForDay(DateTime day, double progress) {
    // Đảm bảo giá trị progress nằm trong khoảng [0.0, 1.0]
    final validProgress = progress.clamp(0.0, 1.0);

    // Tạo key từ ngày (yyyy-MM-dd)
    final key = _formatDateKey(day);

    // Cập nhật giá trị tiến trình
    _progressMap[key] = validProgress;

    // Thông báo thay đổi
    notifyListeners();
  }

  /// Định dạng ngày thành key cho map (yyyy-MM-dd)
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
