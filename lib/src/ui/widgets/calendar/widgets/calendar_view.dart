import 'package:flutter/material.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_config.dart';

import 'month_view.dart';
import 'week_view.dart';
import 'year_view.dart';

/// Widget hiển thị lịch chính
class CalendarView extends StatefulWidget {
  /// Cấu hình lịch
  final CalendarConfig config;

  /// Tháng ban đầu để hiển thị
  final DateTime? initialMonth;

  /// Tuần ban đầu để hiển thị
  final DateTime? initialWeek;

  /// Ngày được chọn ban đầu
  final DateTime? selectedDay;



  /// Chế độ xem ban đầu
  final CalendarViewMode initialViewMode;

  /// Callback khi ngày được chọn
  final Function(DateTime)? onDaySelected;

  /// Callback khi tháng thay đổi
  final Function(DateTime)? onMonthChanged;

  /// Callback khi tuần thay đổi
  final Function(DateTime)? onWeekChanged;

  /// Callback khi chế độ xem thay đổi
  final Function(CalendarViewMode)? onViewModeChanged;

  /// Constructor
  const CalendarView({
    super.key,
    this.config = const CalendarConfig(),
    this.initialMonth,
    this.initialWeek,
    this.selectedDay,
    this.initialViewMode = CalendarViewMode.month,
    this.onDaySelected,
    this.onMonthChanged,
    this.onWeekChanged,
    this.onViewModeChanged,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(
      config: widget.config,
      initialMonth: widget.initialMonth,
      initialWeek: widget.initialWeek,
      selectedDay: widget.selectedDay,
      initialViewMode: widget.initialViewMode,
    );

    // Đăng ký lắng nghe sự thay đổi
    _controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    // Gọi các callback khi có sự thay đổi
    if (widget.onDaySelected != null && _controller.selectedDay != null) {
      widget.onDaySelected!(_controller.selectedDay!);
    }

    if (widget.onMonthChanged != null) {
      widget.onMonthChanged!(_controller.currentMonth);
    }

    if (widget.onWeekChanged != null) {
      widget.onWeekChanged!(_controller.currentWeek);
    }

    if (widget.onViewModeChanged != null) {
      widget.onViewModeChanged!(_controller.viewMode);
    }

    // Cập nhật UI
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header lịch
        _buildHeader(context),

        // Nút chuyển đổi chế độ xem
        _buildViewModeToggle(context),

        // Nội dung lịch
        Expanded(
          child: _buildCalendarContent(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final locale = _controller.config.locale ?? Localizations.localeOf(context);
    String title;
    switch (_controller.viewMode) {
      case CalendarViewMode.year:
        title = 'Năm ${_controller.currentYear.year}';
        break;
      case CalendarViewMode.month:
        title = '${_controller.getMonthName(_controller.currentMonth, locale)} ${_controller.currentMonth.year}';
        break;
      case CalendarViewMode.week:
        title = 'Tuần ${_formatDateRange(_controller.currentWeek)}';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tiêu đề (tháng/năm hoặc tuần)
          Text(
            title,
            style: _controller.config.monthTextStyle ?? Theme.of(context).textTheme.titleLarge,
          ),

          // Nút điều hướng
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  switch (_controller.viewMode) {
                    case CalendarViewMode.year:
                      _controller.previousYear();
                      break;
                    case CalendarViewMode.month:
                      _controller.previousMonth();
                      break;
                    case CalendarViewMode.week:
                      _controller.previousWeek();
                      break;
                  }
                },
                tooltip: _getNavigationTooltip(true),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  switch (_controller.viewMode) {
                    case CalendarViewMode.year:
                      _controller.nextYear();
                      break;
                    case CalendarViewMode.month:
                      _controller.nextMonth();
                      break;
                    case CalendarViewMode.week:
                      _controller.nextWeek();
                      break;
                  }
                },
                tooltip: _getNavigationTooltip(false),
              ),
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: _controller.goToToday,
                tooltip: 'Hôm nay',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment<CalendarViewMode>(
                value: CalendarViewMode.year,
                label: Text('Năm'),
                icon: Icon(Icons.calendar_today),
              ),
              ButtonSegment<CalendarViewMode>(
                value: CalendarViewMode.month,
                label: Text('Tháng'),
                icon: Icon(Icons.calendar_month),
              ),
              ButtonSegment<CalendarViewMode>(
                value: CalendarViewMode.week,
                label: Text('Tuần'),
                icon: Icon(Icons.calendar_view_week),
              ),
            ],
            selected: {_controller.viewMode},
            onSelectionChanged: (Set<CalendarViewMode> selection) {
              if (selection.isNotEmpty) {
                _controller.setViewMode(selection.first);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    switch (_controller.viewMode) {
      case CalendarViewMode.year:
        return YearView(controller: _controller);
      case CalendarViewMode.month:
        return MonthView(controller: _controller);
      case CalendarViewMode.week:
        return WeekView(controller: _controller);
    }
  }

  String _getNavigationTooltip(bool isPrevious) {
    switch (_controller.viewMode) {
      case CalendarViewMode.year:
        return isPrevious ? 'Năm trước' : 'Năm sau';
      case CalendarViewMode.month:
        return isPrevious ? 'Tháng trước' : 'Tháng sau';
      case CalendarViewMode.week:
        return isPrevious ? 'Tuần trước' : 'Tuần sau';
    }
  }

  String _formatDateRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));

    if (startDate.month == endDate.month) {
      return '${startDate.day} - ${endDate.day} ${_getMonthName(startDate.month)}';
    } else if (startDate.year == endDate.year) {
      return '${startDate.day} ${_getMonthName(startDate.month)} - ${endDate.day} ${_getMonthName(endDate.month)}';
    } else {
      return '${startDate.day} ${_getMonthName(startDate.month)} ${startDate.year} - ${endDate.day} ${_getMonthName(endDate.month)} ${endDate.year}';
    }
  }

  String _getMonthName(int month) {
    final locale = _controller.config.locale ?? const Locale('vi');
    final date = DateTime(2024, month, 1);
    return _controller.getMonthName(date, locale);
  }
}
