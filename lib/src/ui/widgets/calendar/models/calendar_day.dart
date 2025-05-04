/// Represents a day in the calendar
class CalendarDay {
  /// The date of this day
  final DateTime date;

  /// Whether this day is in the current month
  final bool isCurrentMonth;

  /// Whether this day is today
  final bool isToday;

  /// Whether this day is a weekend
  final bool isWeekend;

  /// Whether this day is selected
  final bool isSelected;

  /// Constructor
  const CalendarDay({
    required this.date,
    this.isCurrentMonth = true,
    this.isToday = false,
    this.isWeekend = false,
    this.isSelected = false,
  });

  /// Create a copy of this day with some fields replaced
  CalendarDay copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isWeekend,
    bool? isSelected,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isWeekend: isWeekend ?? this.isWeekend,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Check if two days are on the same date
  bool isSameDay(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  @override
  String toString() {
    return 'CalendarDay(date: $date, isCurrentMonth: $isCurrentMonth, isToday: $isToday, isWeekend: $isWeekend, isSelected: $isSelected)';
  }
}
