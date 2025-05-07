import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_provider.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';
import 'package:water_mind/src/core/services/reminders/reminder_service_provider.dart';
import 'package:water_mind/src/core/services/reminders/reminders.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// State cho water history view model
class WaterHistoryState {
  /// Ngày được chọn
  final DateTime selectedDate;

  /// Tuần được chọn (ngày đầu tuần)
  final DateTime selectedWeek;

  /// Tháng được chọn
  final DateTime selectedMonth;

  /// Năm được chọn
  final int selectedYear;

  /// Tab đang active (0: ngày, 1: tuần, 2: tháng, 3: năm)
  final int activeTab;

  /// Lịch sử uống nước theo ngày
  final AsyncValue<WaterIntakeHistory?> dailyHistory;

  /// Lịch sử uống nước theo tuần
  final AsyncValue<List<WaterIntakeHistory>> weeklyHistory;

  /// Lịch sử uống nước theo tháng
  final AsyncValue<List<WaterIntakeHistory>> monthlyHistory;

  /// Lịch sử uống nước theo năm
  final AsyncValue<List<WaterIntakeHistory>> yearlyHistory;

  /// Cài đặt nhắc nhở
  final AsyncValue<WaterReminderModel> reminderSettings;

  /// Constructor
  WaterHistoryState({
    required this.selectedDate,
    required this.selectedWeek,
    required this.selectedMonth,
    required this.selectedYear,
    required this.activeTab,
    required this.dailyHistory,
    required this.weeklyHistory,
    required this.monthlyHistory,
    required this.yearlyHistory,
    required this.reminderSettings,
  });

  /// Copy with
  WaterHistoryState copyWith({
    DateTime? selectedDate,
    DateTime? selectedWeek,
    DateTime? selectedMonth,
    int? selectedYear,
    int? activeTab,
    AsyncValue<WaterIntakeHistory?>? dailyHistory,
    AsyncValue<List<WaterIntakeHistory>>? weeklyHistory,
    AsyncValue<List<WaterIntakeHistory>>? monthlyHistory,
    AsyncValue<List<WaterIntakeHistory>>? yearlyHistory,
    AsyncValue<WaterReminderModel>? reminderSettings,
  }) {
    return WaterHistoryState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      activeTab: activeTab ?? this.activeTab,
      dailyHistory: dailyHistory ?? this.dailyHistory,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      monthlyHistory: monthlyHistory ?? this.monthlyHistory,
      yearlyHistory: yearlyHistory ?? this.yearlyHistory,
      reminderSettings: reminderSettings ?? this.reminderSettings,
    );
  }
}

/// Provider cho water history view model
final waterHistoryViewModelProvider = StateNotifierProvider<WaterHistoryViewModel, WaterHistoryState>((ref) {
  final waterIntakeRepository = ref.watch(waterIntakeRepositoryProvider);
  final reminderService = ref.watch(reminderServiceProvider);

  // Lấy ngày hiện tại
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Lấy ngày đầu tuần
  final startOfWeek = DateTimeUtils.getStartOfWeek(today);

  // Lấy ngày đầu tháng
  final startOfMonth = DateTime(now.year, now.month, 1);

  return WaterHistoryViewModel(
    waterIntakeRepository,
    reminderService,
    ref,
  );
});

/// View model cho water history
class WaterHistoryViewModel extends StateNotifier<WaterHistoryState> {
  final WaterIntakeRepository _waterIntakeRepository;
  final ReminderServiceInterface _reminderService;
  final Ref _ref;

  /// Constructor
  WaterHistoryViewModel(
    this._waterIntakeRepository,
    this._reminderService,
    this._ref,
  ) : super(
    WaterHistoryState(
      selectedDate: DateTime.now(),
      selectedWeek: DateTimeUtils.getStartOfWeek(DateTime.now()),
      selectedMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
      selectedYear: DateTime.now().year,
      activeTab: 0,
      dailyHistory: const AsyncValue.loading(),
      weeklyHistory: const AsyncValue.loading(),
      monthlyHistory: const AsyncValue.loading(),
      yearlyHistory: const AsyncValue.loading(),
      reminderSettings: const AsyncValue.loading(),
    ),
  ) {
    _init();
  }

  /// Initialize
  Future<void> _init() async {
    // Lấy cài đặt nhắc nhở
    _loadReminderSettings();

    // Lấy dữ liệu theo ngày
    _loadDailyData(state.selectedDate);
  }

  /// Lấy cài đặt nhắc nhở
  Future<void> _loadReminderSettings() async {
    try {
      final settings = await _reminderService.getReminderSettings();
      state = state.copyWith(
        reminderSettings: AsyncValue.data(settings),
      );
    } catch (e) {
      state = state.copyWith(
        reminderSettings: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Lấy dữ liệu theo ngày
  Future<void> _loadDailyData(DateTime date) async {
    state = state.copyWith(
      dailyHistory: const AsyncValue.loading(),
    );

    try {
      final history = await _waterIntakeRepository.getWaterIntakeHistory(date);
      state = state.copyWith(
        dailyHistory: AsyncValue.data(history),
      );
    } catch (e) {
      state = state.copyWith(
        dailyHistory: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Đặt ngày được chọn
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    _loadDailyData(date);
  }

  /// Đặt tuần được chọn
  void setSelectedWeek(DateTime week) {
    state = state.copyWith(selectedWeek: week);
    _loadWeeklyData(week);
  }

  /// Đặt tháng được chọn
  void setSelectedMonth(DateTime month) {
    state = state.copyWith(selectedMonth: month);
    _loadMonthlyData(month);
  }

  /// Đặt năm được chọn
  void setSelectedYear(int year) {
    state = state.copyWith(selectedYear: year);
    _loadYearlyData(year);
  }

  /// Đặt tab đang active
  void setActiveTab(int tab) {
    state = state.copyWith(activeTab: tab);

    // Tải dữ liệu tương ứng với tab
    switch (tab) {
      case 0: // Ngày
        _loadDailyData(state.selectedDate);
        break;
      case 1: // Tuần
        _loadWeeklyData(state.selectedWeek);
        break;
      case 2: // Tháng
        _loadMonthlyData(state.selectedMonth);
        break;
      case 3: // Năm
        _loadYearlyData(state.selectedYear);
        break;
    }
  }

  /// Lấy dữ liệu theo tuần
  Future<void> _loadWeeklyData(DateTime startOfWeek) async {
    state = state.copyWith(
      weeklyHistory: const AsyncValue.loading(),
    );

    try {
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final histories = <WaterIntakeHistory>[];

      // Lấy dữ liệu cho 7 ngày trong tuần
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final history = await _waterIntakeRepository.getWaterIntakeHistory(date);
        if (history != null) {
          histories.add(history);
        }
      }

      state = state.copyWith(
        weeklyHistory: AsyncValue.data(histories),
      );
    } catch (e) {
      state = state.copyWith(
        weeklyHistory: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Lấy dữ liệu theo tháng
  Future<void> _loadMonthlyData(DateTime month) async {
    state = state.copyWith(
      monthlyHistory: const AsyncValue.loading(),
    );

    try {
      final daysInMonth = DateTimeUtils.getDaysInMonth(month.year, month.month);
      final histories = <WaterIntakeHistory>[];

      // Lấy dữ liệu cho tất cả các ngày trong tháng
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(month.year, month.month, i);
        final history = await _waterIntakeRepository.getWaterIntakeHistory(date);
        if (history != null) {
          histories.add(history);
        }
      }

      state = state.copyWith(
        monthlyHistory: AsyncValue.data(histories),
      );
    } catch (e) {
      state = state.copyWith(
        monthlyHistory: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Lấy dữ liệu theo năm
  Future<void> _loadYearlyData(int year) async {
    state = state.copyWith(
      yearlyHistory: const AsyncValue.loading(),
    );

    try {
      final histories = <WaterIntakeHistory>[];

      // Lấy tất cả lịch sử uống nước
      final allHistories = await _waterIntakeRepository.getAllWaterIntakeHistory();

      // Lọc theo năm
      for (final history in allHistories) {
        if (history.date.year == year) {
          histories.add(history);
        }
      }

      state = state.copyWith(
        yearlyHistory: AsyncValue.data(histories),
      );
    } catch (e) {
      state = state.copyWith(
        yearlyHistory: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Lấy danh sách các điểm cho biểu đồ ngày
  List<FlSpot> getDailyChartSpots() {
    final history = state.dailyHistory.valueOrNull;
    if (history == null) {
      return [];
    }

    // Nhóm các entries theo giờ
    final hourlyData = <int, double>{};
    for (final entry in history.entries) {
      final hour = entry.timestamp.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + entry.amount;
    }

    // Tạo danh sách FlSpot
    final spots = <FlSpot>[];
    for (int hour = 0; hour < 24; hour++) {
      spots.add(FlSpot(hour.toDouble(), hourlyData[hour] ?? 0));
    }

    return spots;
  }

  /// Lấy danh sách các điểm cho biểu đồ tuần
  List<FlSpot> getWeeklyChartSpots() {
    final histories = state.weeklyHistory.valueOrNull;
    if (histories == null || histories.isEmpty) {
      return [];
    }

    // Tạo danh sách FlSpot
    final spots = <FlSpot>[];
    for (int day = 0; day < 7; day++) {
      double totalAmount = 0;

      // Tìm lịch sử cho ngày này
      final date = state.selectedWeek.add(Duration(days: day));
      for (final history in histories) {
        if (DateTimeUtils.isSameDay(history.date, date)) {
          totalAmount = history.totalAmount;
          break;
        }
      }

      spots.add(FlSpot(day.toDouble(), totalAmount));
    }

    return spots;
  }

  /// Lấy danh sách các điểm cho biểu đồ tháng
  List<FlSpot> getMonthlyChartSpots() {
    final histories = state.monthlyHistory.valueOrNull;
    if (histories == null || histories.isEmpty) {
      return [];
    }

    // Tạo danh sách FlSpot
    final spots = <FlSpot>[];
    final daysInMonth = DateTimeUtils.getDaysInMonth(
      state.selectedMonth.year,
      state.selectedMonth.month,
    );

    for (int day = 1; day <= daysInMonth; day++) {
      double totalAmount = 0;

      // Tìm lịch sử cho ngày này
      final date = DateTime(state.selectedMonth.year, state.selectedMonth.month, day);
      for (final history in histories) {
        if (DateTimeUtils.isSameDay(history.date, date)) {
          totalAmount = history.totalAmount;
          break;
        }
      }

      spots.add(FlSpot(day.toDouble(), totalAmount));
    }

    return spots;
  }

  /// Lấy danh sách các điểm cho biểu đồ năm
  List<FlSpot> getYearlyChartSpots() {
    final histories = state.yearlyHistory.valueOrNull;
    if (histories == null || histories.isEmpty) {
      return [];
    }

    // Nhóm các lịch sử theo tháng
    final monthlyData = <int, double>{};
    for (final history in histories) {
      final month = history.date.month;
      monthlyData[month] = (monthlyData[month] ?? 0) + history.totalAmount;
    }

    // Tạo danh sách FlSpot
    final spots = <FlSpot>[];
    for (int month = 1; month <= 12; month++) {
      spots.add(FlSpot(month.toDouble(), monthlyData[month] ?? 0));
    }

    return spots;
  }

  /// Lấy danh sách thời gian nhắc nhở trong ngày
  List<TimeOfDay> getReminderTimes() {
    final settings = state.reminderSettings.valueOrNull;
    if (settings == null) {
      return [];
    }

    switch (settings.mode) {
      case ReminderMode.standard:
        // Tính toán các thời điểm nhắc nhở theo chế độ tiêu chuẩn
        final wakeUpTime = settings.wakeUpTime;
        final bedTime = settings.bedTime;

        // Tính tổng số phút trong ngày hoạt động
        int wakeTimeMinutes = wakeUpTime.hour * 60 + wakeUpTime.minute;
        int bedTimeMinutes = bedTime.hour * 60 + bedTime.minute;

        // Xử lý trường hợp thời gian đi ngủ là ngày hôm sau
        if (bedTimeMinutes < wakeTimeMinutes) {
          bedTimeMinutes += 24 * 60;
        }

        final activePeriodMinutes = bedTimeMinutes - wakeTimeMinutes;

        // Tính số lượng nhắc nhở và khoảng thời gian
        final reminderCount = activePeriodMinutes >= 720 ? 8 : 6;
        final interval = activePeriodMinutes / (reminderCount + 1);

        // Tạo danh sách các thời điểm nhắc nhở
        final reminderTimes = <TimeOfDay>[];
        for (int i = 1; i <= reminderCount; i++) {
          final reminderTimeMinutes = (wakeTimeMinutes + (interval * i).round()) % (24 * 60);
          final reminderHour = reminderTimeMinutes ~/ 60;
          final reminderMinute = reminderTimeMinutes % 60;

          reminderTimes.add(TimeOfDay(hour: reminderHour, minute: reminderMinute));
        }

        return reminderTimes;

      case ReminderMode.interval:
        // Tính toán các thời điểm nhắc nhở theo khoảng thời gian
        final wakeUpTime = settings.wakeUpTime;
        final bedTime = settings.bedTime;
        final interval = settings.intervalMinutes;

        // Tính tổng số phút trong ngày hoạt động
        int wakeTimeMinutes = wakeUpTime.hour * 60 + wakeUpTime.minute;
        int bedTimeMinutes = bedTime.hour * 60 + bedTime.minute;

        // Xử lý trường hợp thời gian đi ngủ là ngày hôm sau
        if (bedTimeMinutes < wakeTimeMinutes) {
          bedTimeMinutes += 24 * 60;
        }

        final activePeriodMinutes = bedTimeMinutes - wakeTimeMinutes;

        // Tính số lượng nhắc nhở
        final reminderCount = activePeriodMinutes ~/ interval;

        // Tạo danh sách các thời điểm nhắc nhở
        final reminderTimes = <TimeOfDay>[];
        for (int i = 0; i < reminderCount; i++) {
          final reminderTimeMinutes = (wakeTimeMinutes + (interval * (i + 1))) % (24 * 60);
          final reminderHour = reminderTimeMinutes ~/ 60;
          final reminderMinute = reminderTimeMinutes % 60;

          reminderTimes.add(TimeOfDay(hour: reminderHour, minute: reminderMinute));
        }

        return reminderTimes;

      case ReminderMode.custom:
        // Sử dụng các thời điểm tùy chỉnh
        return settings.customTimes;
    }
  }

  /// Tạo dữ liệu giả cho 7 ngày gần đây
  Future<void> generateFakeDataForLastWeek() async {
    // Xóa dữ liệu cũ
    await _waterIntakeRepository.clearAllWaterIntakeHistory();

    final random = Random();
    final uuid = const Uuid();
    final today = DateTime.now();

    // Tạo dữ liệu cho 7 ngày gần đây
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Tạo mục tiêu ngẫu nhiên từ 2000ml đến 3000ml
      final dailyGoal = 2000.0 + random.nextDouble() * 1000.0;

      // Tạo số lượng entries ngẫu nhiên từ 3 đến 8
      final entryCount = 3 + random.nextInt(6);

      // Tạo danh sách entries
      final entries = <WaterIntakeEntry>[];

      // Tổng lượng nước đã uống
      double totalAmount = 0;

      for (int j = 0; j < entryCount; j++) {
        // Tạo thời gian ngẫu nhiên trong ngày
        final hour = 8 + random.nextInt(14); // Từ 8h sáng đến 22h tối
        final minute = random.nextInt(60);
        final timestamp = DateTime(
          normalizedDate.year,
          normalizedDate.month,
          normalizedDate.day,
          hour,
          minute,
        );

        // Chọn loại đồ uống ngẫu nhiên
        final drinkType = DrinkTypes.all[random.nextInt(DrinkTypes.all.length)];

        // Tạo lượng nước ngẫu nhiên từ 150ml đến 350ml
        final amount = 150.0 + random.nextDouble() * 200.0;

        // Tạo entry mới
        final entry = WaterIntakeEntry(
          id: uuid.v4(),
          timestamp: timestamp,
          amount: amount,
          drinkType: drinkType,
          note: _getRandomNote(random),
        );

        entries.add(entry);
        totalAmount += entry.effectiveAmount;
      }

      // Nếu tổng lượng nước chưa đạt mục tiêu và xác suất 70%, thêm một entry để đạt mục tiêu
      if (totalAmount < dailyGoal && random.nextDouble() < 0.7) {
        final remainingAmount = dailyGoal - totalAmount;

        final hour = 20 + random.nextInt(3); // Từ 20h đến 22h tối
        final minute = random.nextInt(60);
        final timestamp = DateTime(
          normalizedDate.year,
          normalizedDate.month,
          normalizedDate.day,
          hour,
          minute,
        );

        final entry = WaterIntakeEntry(
          id: uuid.v4(),
          timestamp: timestamp,
          amount: remainingAmount,
          drinkType: DrinkTypes.water, // Nước lọc
          note: 'Uống để đạt mục tiêu',
        );

        entries.add(entry);
      }

      // Sắp xếp entries theo thời gian
      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Tạo history
      final history = WaterIntakeHistory(
        date: normalizedDate,
        entries: entries,
        dailyGoal: dailyGoal,
        measureUnit: MeasureUnit.metric,
      );

      // Lưu history
      await _waterIntakeRepository.saveWaterIntakeHistory(history);
    }

    // Tải lại dữ liệu
    _loadDailyData(state.selectedDate);
    _loadWeeklyData(state.selectedWeek);
    _loadMonthlyData(state.selectedMonth);
    _loadYearlyData(state.selectedYear);
  }

  /// Tạo dữ liệu giả cho 30 ngày gần đây
  Future<void> generateFakeDataForLastMonth() async {
    // Xóa dữ liệu cũ
    await _waterIntakeRepository.clearAllWaterIntakeHistory();

    final random = Random();
    final uuid = const Uuid();
    final today = DateTime.now();

    // Tạo dữ liệu cho 30 ngày gần đây
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Tạo mục tiêu ngẫu nhiên từ 2000ml đến 3000ml
      final dailyGoal = 2000.0 + random.nextDouble() * 1000.0;

      // Tạo số lượng entries ngẫu nhiên từ 3 đến 8
      final entryCount = 3 + random.nextInt(6);

      // Tạo danh sách entries
      final entries = <WaterIntakeEntry>[];

      // Tổng lượng nước đã uống
      double totalAmount = 0;

      for (int j = 0; j < entryCount; j++) {
        // Tạo thời gian ngẫu nhiên trong ngày
        final hour = 8 + random.nextInt(14); // Từ 8h sáng đến 22h tối
        final minute = random.nextInt(60);
        final timestamp = DateTime(
          normalizedDate.year,
          normalizedDate.month,
          normalizedDate.day,
          hour,
          minute,
        );

        // Chọn loại đồ uống ngẫu nhiên
        final drinkType = DrinkTypes.all[random.nextInt(DrinkTypes.all.length)];

        // Tạo lượng nước ngẫu nhiên từ 150ml đến 350ml
        final amount = 150.0 + random.nextDouble() * 200.0;

        // Tạo entry mới
        final entry = WaterIntakeEntry(
          id: uuid.v4(),
          timestamp: timestamp,
          amount: amount,
          drinkType: drinkType,
          note: _getRandomNote(random),
        );

        entries.add(entry);
        totalAmount += entry.effectiveAmount;
      }

      // Nếu tổng lượng nước chưa đạt mục tiêu và xác suất 70%, thêm một entry để đạt mục tiêu
      if (totalAmount < dailyGoal && random.nextDouble() < 0.7) {
        final remainingAmount = dailyGoal - totalAmount;

        final hour = 20 + random.nextInt(3); // Từ 20h đến 22h tối
        final minute = random.nextInt(60);
        final timestamp = DateTime(
          normalizedDate.year,
          normalizedDate.month,
          normalizedDate.day,
          hour,
          minute,
        );

        final entry = WaterIntakeEntry(
          id: uuid.v4(),
          timestamp: timestamp,
          amount: remainingAmount,
          drinkType: DrinkTypes.water, // Nước lọc
          note: 'Uống để đạt mục tiêu',
        );

        entries.add(entry);
      }

      // Sắp xếp entries theo thời gian
      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Tạo history
      final history = WaterIntakeHistory(
        date: normalizedDate,
        entries: entries,
        dailyGoal: dailyGoal,
        measureUnit: MeasureUnit.metric,
      );

      // Lưu history
      await _waterIntakeRepository.saveWaterIntakeHistory(history);
    }

    // Tải lại dữ liệu
    _loadDailyData(state.selectedDate);
    _loadWeeklyData(state.selectedWeek);
    _loadMonthlyData(state.selectedMonth);
    _loadYearlyData(state.selectedYear);
  }

  /// Tạo ghi chú ngẫu nhiên
  String? _getRandomNote(Random random) {
    // 70% trường hợp không có ghi chú
    if (random.nextDouble() < 0.7) {
      return null;
    }

    final notes = [
      'Uống sau khi tập thể dục',
      'Uống khi làm việc',
      'Uống trước khi đi ngủ',
      'Uống sau bữa ăn',
      'Uống khi khát',
      'Uống khi nhắc nhở',
      'Uống khi đi dạo',
      'Uống khi xem phim',
      'Uống khi đọc sách',
      'Uống khi chơi game',
    ];

    return notes[random.nextInt(notes.length)];
  }
}
