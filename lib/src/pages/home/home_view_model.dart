import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:water_mind/src/core/database/providers/user_preferences_providers.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/water_intake_entry.dart';
import 'package:water_mind/src/core/models/water_intake_history.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/hydration/hydration_service_provider.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_change_notifier.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_provider.dart';
import 'package:water_mind/src/core/services/hydration/water_intake_repository.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/amount_wheel_sheet.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/drink_type_wheel_sheet.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/premium_amount_wheel_sheet.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/premium_drink_type_wheel_sheet.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/pages/home/home_state.dart';
import 'package:water_mind/src/ui/widgets/bottom_sheets/water_intake_editor_sheet.dart';
import 'package:water_mind/src/ui/widgets/calendar/controllers/calendar_controller.dart';

/// Provider cho user data
final userDataProvider = FutureProvider<UserOnboardingModel?>((ref) async {
  // Lấy dữ liệu người dùng từ repository
  // Đây chỉ là mẫu, cần thay thế bằng repository thực tế
  return const UserOnboardingModel(
    measureUnit: MeasureUnit.metric,
  );
});

/// Provider cho user preferences
final userPreferencesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Lấy dữ liệu tùy chọn người dùng từ repository
  // Đây chỉ là mẫu, cần thay thế bằng repository thực tế
  return {
    'lastDrinkTypeId': 'water',
    'lastDrinkAmount': 200.0,
  };
});

/// Provider cho HomeViewModel
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final waterIntakeRepository = ref.watch(waterIntakeRepositoryProvider);

  // Tạo calendar controller
  final calendarController = CalendarController();

  return HomeViewModel(
    waterIntakeRepository,
    ref,
    calendarController,
  );
});

/// ViewModel cho màn hình home
class HomeViewModel extends StateNotifier<HomeState> {
  final WaterIntakeRepository _waterIntakeRepository;
  final Ref _ref;
  Timer? _waveAnimationTimer;
  final CalendarController _calendarController;

  /// Constructor
  HomeViewModel(
    this._waterIntakeRepository,
    this._ref,
    this._calendarController,
  ) : super(
    HomeState(
      selectedDate: DateTime.now(),
      todayHistory: const AsyncValue.loading(),
      userModel: const AsyncValue.loading(),
      calendarController: null,
    ),
  ) {
    _init();
  }

  @override
  void dispose() {
    _waveAnimationTimer?.cancel();
    super.dispose();
  }

  /// Initialize
  Future<void> _init() async {
    // Bắt đầu animation cho sóng nước
    _startWaveAnimation();

    // Lấy dữ liệu người dùng
    await _loadUserData();

    // Chuẩn hóa ngày hiện tại
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    debugPrint('HOME_VM: Initializing with normalized date: ${normalizedToday.toIso8601String().split('T')[0]}');

    // Cập nhật state với ngày đã chuẩn hóa
    state = state.copyWith(selectedDate: normalizedToday);

    // Lấy dữ liệu lịch sử uống nước
    await _loadWaterIntakeHistory(normalizedToday);

    // Lấy thông tin loại đồ uống và lượng nước gần nhất
    await _loadLastDrinkInfo();

    // Lắng nghe sự thay đổi dữ liệu từ waterIntakeChangeNotifierProvider
    _listenToDataChanges();
  }

  /// Lắng nghe sự thay đổi dữ liệu
  void _listenToDataChanges() {
    // Đăng ký lắng nghe sự kiện thay đổi dữ liệu
    _ref.listen(waterIntakeChangeNotifierProvider, (previous, current) {
      debugPrint('HOME_VM: Detected data change at ${current.toString()}');

      // Tải lại dữ liệu lịch sử uống nước cho ngày hiện tại
      _loadWaterIntakeHistory(state.selectedDate);
    });
  }

  /// Bắt đầu animation cho sóng nước
  void _startWaveAnimation() {
    _waveAnimationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      state = state.copyWith(
        wavePhase: state.wavePhase + 0.05,
      );
    });
  }

  /// Lấy dữ liệu người dùng
  Future<void> _loadUserData() async {
    try {
      // Lấy dữ liệu người dùng từ repository
      final userData = await _ref.read(userDataProvider.future);
      state = state.copyWith(
        userModel: AsyncValue.data(userData),
      );
    } catch (e) {
      state = state.copyWith(
        userModel: AsyncValue.error(e, StackTrace.current),
        errorMessage: 'Không thể tải dữ liệu người dùng',
      );
    }
  }

  /// Lấy dữ liệu lịch sử uống nước
  Future<void> _loadWaterIntakeHistory(DateTime date) async {
    try {
      state = state.copyWith(isLoading: true);

      // Lấy lịch sử uống nước từ repository
      final history = await _waterIntakeRepository.getWaterIntakeHistory(date);

      // Log để debug
      debugPrint('HOME_VM: Loading water history for ${date.toIso8601String().split('T')[0]}');
      debugPrint('HOME_VM: History found: ${history != null}');
      if (history != null) {
        debugPrint('HOME_VM: Entries count: ${history.entries.length}');
        debugPrint('HOME_VM: Total amount: ${history.totalAmount} ml');
        // Log chi tiết từng entry
        for (var entry in history.entries) {
          debugPrint('HOME_VM: Entry ID: ${entry.id}, Amount: ${entry.amount}, Type: ${entry.drinkType.name}, Time: ${entry.timestamp}');
        }
      }

      // Nếu không có lịch sử, tạo mới với mục tiêu được tính toán từ dữ liệu người dùng
      if (history == null) {
        final userModel = state.userModel.valueOrNull;

        // Tính toán mục tiêu dựa trên dữ liệu người dùng và profile settings
        double recommendedGoal = 2500; // Mục tiêu mặc định
        final measureUnit = userModel?.measureUnit ?? MeasureUnit.metric;

        // Kiểm tra xem có custom daily goal trong profile settings không
        try {
          // Lấy profile settings từ SharedPreferences
          final profileSettingsJson = KVStoreService.sharedPreferences.getString('profile_settings');
          if (profileSettingsJson != null) {
            final profileSettings = jsonDecode(profileSettingsJson) as Map<String, dynamic>;

            // Nếu người dùng đã thiết lập custom daily goal
            if (profileSettings['useCustomDailyGoal'] == true && profileSettings['customDailyGoal'] != null) {
              recommendedGoal = profileSettings['customDailyGoal'].toDouble();
              debugPrint('Using custom daily goal from profile settings: $recommendedGoal');

              // Cập nhật đơn vị đo nếu có
              if (profileSettings['measureUnit'] != null) {
                final unit = profileSettings['measureUnit'] == 0 ? MeasureUnit.metric : MeasureUnit.imperial;
                debugPrint('Using measure unit from profile settings: $unit');
              }
            } else if (userModel != null) {
              // Nếu không có custom daily goal, sử dụng hydration service
              final hydrationService = _ref.read(hydrationServiceProvider);
              final hydrationModel = hydrationService.calculateFromUserModel(userModel);
              recommendedGoal = hydrationModel.dailyWaterIntake;
              debugPrint('Calculated recommended goal: $recommendedGoal ${hydrationModel.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
            }
          } else if (userModel != null) {
            // Nếu không có profile settings, sử dụng hydration service
            final hydrationService = _ref.read(hydrationServiceProvider);
            final hydrationModel = hydrationService.calculateFromUserModel(userModel);
            recommendedGoal = hydrationModel.dailyWaterIntake;
            debugPrint('Calculated recommended goal: $recommendedGoal ${hydrationModel.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
          }
        } catch (e) {
          debugPrint('Error getting daily goal from profile settings: $e');

          // Fallback to hydration service
          if (userModel != null) {
            final hydrationService = _ref.read(hydrationServiceProvider);
            final hydrationModel = hydrationService.calculateFromUserModel(userModel);
            recommendedGoal = hydrationModel.dailyWaterIntake;
            debugPrint('Fallback to calculated recommended goal: $recommendedGoal ${hydrationModel.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
          }
        }

        final defaultHistory = WaterIntakeHistory(
          date: date,
          entries: [],
          dailyGoal: recommendedGoal,
          measureUnit: measureUnit,
        );

        // Lưu lịch sử mặc định vào repository
        await _waterIntakeRepository.saveWaterIntakeHistory(defaultHistory);

        state = state.copyWith(
          todayHistory: AsyncValue.data(defaultHistory),
          isLoading: false,
        );

        debugPrint('Created default history with goal: ${defaultHistory.dailyGoal} ${defaultHistory.measureUnit == MeasureUnit.metric ? 'ml' : 'fl oz'}');
      } else {
        state = state.copyWith(
          todayHistory: AsyncValue.data(history),
          isLoading: false,
        );

        debugPrint('Updated state with history: ${history.entries.length} entries, total: ${history.totalAmount} ml');
      }
    } catch (e) {
      debugPrint('Error loading water intake history: $e');
      state = state.copyWith(
        todayHistory: AsyncValue.error(e, StackTrace.current),
        isLoading: false,
        errorMessage: 'Không thể tải lịch sử uống nước: $e',
      );
    }
  }

  /// Lấy thông tin loại đồ uống và lượng nước gần nhất
  Future<void> _loadLastDrinkInfo() async {
    try {
      // Lấy thông tin từ repository
      final userPreferencesRepository = _ref.read(userPreferencesRepositoryProvider);
      final preferences = await userPreferencesRepository.getUserPreferences();

      if (preferences != null) {
        // Lấy loại đồ uống
        final lastDrinkTypeId = preferences.lastDrinkTypeId;
        if (lastDrinkTypeId != null) {
          final drinkType = DrinkTypes.all.firstWhere(
            (d) => d.id == lastDrinkTypeId,
            orElse: () => DrinkTypes.water,
          );
          state = state.copyWith(selectedDrinkType: drinkType);
        }

        // Lấy lượng nước
        final lastDrinkAmount = preferences.lastDrinkAmount;
        if (lastDrinkAmount != null) {
          state = state.copyWith(selectedAmount: lastDrinkAmount);
        }
      }
    } catch (e) {
      // Không cần hiển thị lỗi, sử dụng giá trị mặc định
      state = state.copyWith(
        selectedDrinkType: DrinkTypes.water,
        selectedAmount: 200.0,
      );
      debugPrint('Error loading last drink info: $e');
    }
  }

  /// Chọn ngày
  Future<void> selectDate(DateTime date) async {
    if (date != state.selectedDate) {
      // Chuẩn hóa ngày để đảm bảo chỉ có ngày, tháng, năm (không có giờ, phút, giây)
      final normalizedDate = DateTime(date.year, date.month, date.day);
      debugPrint('HOME_VM: Selecting date: ${normalizedDate.toIso8601String().split('T')[0]}');

      state = state.copyWith(selectedDate: normalizedDate);
      await _loadWaterIntakeHistory(normalizedDate);
    }
  }

  /// Đặt loại đồ uống đã chọn
  void setSelectedDrinkType(DrinkType drinkType) {
    HapticService.instance.feedback(HapticFeedbackType.selection);
    state = state.copyWith(selectedDrinkType: drinkType);
  }

  /// Đặt lượng nước đã chọn
  void setSelectedAmount(double amount) {
    HapticService.instance.feedback(HapticFeedbackType.selection);
    state = state.copyWith(selectedAmount: amount);
  }

  /// Hiển thị bottom sheet chọn loại đồ uống
  Future<void> showDrinkTypeSelector(BuildContext context) async {
    final initialDrinkType = state.selectedDrinkType;

    // Use premium drink type wheel sheet
    final result = await PremiumDrinkTypeWheelSheet.show(
      context: context,
      initialDrinkType: initialDrinkType,
    );

    if (result != null) {
      setSelectedDrinkType(result);
      // Lưu thông tin loại đồ uống gần nhất
      await _updateLastDrinkInfo(result.id, state.selectedAmount);
    }
  }

  /// Hiển thị bottom sheet chọn lượng nước
  Future<void> showWaterAmountSelector(BuildContext context) async {
    final measureUnit = state.userModel.valueOrNull?.measureUnit ?? MeasureUnit.metric;
    final initialAmount = state.selectedAmount;

    // Use premium amount wheel sheet
    final result = await PremiumAmountWheelSheet.show(
      context: context,
      initialAmount: initialAmount,
      measureUnit: measureUnit,
    );

    if (result != null) {
      setSelectedAmount(result);
      // Lưu thông tin lượng nước gần nhất
      await _updateLastDrinkInfo(state.selectedDrinkType.id, result);
    }
  }

  /// Thêm một lần uống nước mới
  Future<void> addWaterIntakeEntry() async {
    try {
      // Kiểm tra xem đã chọn lượng nước chưa
      if (state.selectedAmount <= 0) {
        state = state.copyWith(
          errorMessage: 'Vui lòng chọn lượng nước hợp lệ',
        );
        return;
      }

      // Lưu mực nước hiện tại để sử dụng cho animation
      final currentWaterLevel = state.todayHistory.valueOrNull?.progressPercentage.clamp(0.0, 1.0) ?? 0.0;

      state = state.copyWith(
        isLoading: true,
        previousWaterLevel: currentWaterLevel,
      );
      debugPrint('HOME_VM: Adding water intake entry: ${state.selectedAmount} ml of ${state.selectedDrinkType.name}');
      debugPrint('HOME_VM: Current water level before adding: $currentWaterLevel');

      // Tạo entry mới với timestamp đã chuẩn hóa giờ, phút, giây nhưng giữ nguyên ngày
      final now = DateTime.now();
      final timestamp = DateTime(
        state.selectedDate.year,
        state.selectedDate.month,
        state.selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      final entry = WaterIntakeEntry(
        id: const Uuid().v4(),
        timestamp: timestamp,
        amount: state.selectedAmount,
        drinkType: state.selectedDrinkType,
      );

      debugPrint('HOME_VM: Created entry with timestamp: ${entry.timestamp}, for date: ${state.selectedDate.toIso8601String().split('T')[0]}');

      // Thêm vào repository
      debugPrint('HOME_VM: Adding entry with ID: ${entry.id} to repository');
      await _waterIntakeRepository.addWaterIntakeEntry(state.selectedDate, entry);
      debugPrint('HOME_VM: Entry added successfully');

      // Cập nhật thông tin uống nước gần nhất
      await _updateLastDrinkInfo(state.selectedDrinkType.id, state.selectedAmount);

      // Tải lại dữ liệu
      debugPrint('HOME_VM: Reloading water history after adding entry');
      await _loadWaterIntakeHistory(state.selectedDate);

      // Thông báo thành công
      HapticService.instance.feedback(HapticFeedbackType.success);
    } catch (e) {
      debugPrint('Error adding water intake entry: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể thêm lần uống nước mới: $e',
      );

      // Thông báo lỗi
      HapticService.instance.feedback(HapticFeedbackType.error);
    }
  }

  /// Cập nhật thông tin uống nước gần nhất
  Future<void> _updateLastDrinkInfo(String drinkTypeId, double amount) async {
    try {
      // Cập nhật state
      state = state.copyWith(
        selectedDrinkType: DrinkTypes.all.firstWhere((d) => d.id == drinkTypeId, orElse: () => DrinkTypes.water),
        selectedAmount: amount,
      );

      // Lưu thông tin vào repository
      final userPreferencesRepository = _ref.read(userPreferencesRepositoryProvider);
      await userPreferencesRepository.updateLastDrinkInfo(drinkTypeId, amount);
    } catch (e) {
      // Không cần hiển thị lỗi, chỉ ghi log
      debugPrint('Error updating last drink info: $e');
    }
  }

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntakeEntry(String entryId) async {
    try {
      state = state.copyWith(isLoading: true);
      debugPrint('HOME_VM: Deleting water intake entry with ID: $entryId');

      // Xóa từ repository
      await _waterIntakeRepository.deleteWaterIntakeEntry(state.selectedDate, entryId);
      debugPrint('HOME_VM: Entry deleted successfully');

      // Tải lại dữ liệu
      debugPrint('HOME_VM: Reloading water history after deleting entry');
      await _loadWaterIntakeHistory(state.selectedDate);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể xóa lần uống nước',
      );
    }
  }

  /// Chỉnh sửa một lần uống nước
  Future<void> editWaterIntakeEntry(BuildContext context, WaterIntakeEntry entry) async {
    try {
      final measureUnit = state.todayHistory.valueOrNull?.measureUnit ?? MeasureUnit.metric;

      // Hiển thị bottom sheet chỉnh sửa
      final result = await WaterIntakeEditorSheet.show(
        context: context,
        initialAmount: entry.amount,
        initialTime: TimeOfDay.fromDateTime(entry.timestamp),
        initialDrinkType: entry.drinkType,
        initialNote: entry.note,
        measureUnit: measureUnit,
      );

      if (result != null) {
        state = state.copyWith(isLoading: true);

        // Tạo entry mới với thông tin đã chỉnh sửa
        final updatedEntry = WaterIntakeEntry(
          id: entry.id,
          timestamp: DateTime(
            entry.timestamp.year,
            entry.timestamp.month,
            entry.timestamp.day,
            result.time.hour,
            result.time.minute,
          ),
          amount: result.amount,
          drinkType: result.drinkType,
          note: result.note,
        );

        // Lấy lịch sử hiện tại
        final history = state.todayHistory.valueOrNull;
        if (history != null) {
          // Tìm và thay thế entry cũ
          final entries = List<WaterIntakeEntry>.from(history.entries);
          final index = entries.indexWhere((e) => e.id == entry.id);
          if (index != -1) {
            entries[index] = updatedEntry;
          }

          // Tạo lịch sử mới
          final updatedHistory = WaterIntakeHistory(
            date: history.date,
            entries: entries,
            dailyGoal: history.dailyGoal,
            measureUnit: history.measureUnit,
          );

          // Lưu vào repository
          await _waterIntakeRepository.saveWaterIntakeHistory(updatedHistory);

          // Tải lại dữ liệu
          await _loadWaterIntakeHistory(state.selectedDate);
        }

        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể chỉnh sửa lần uống nước',
      );
    }
  }
}
