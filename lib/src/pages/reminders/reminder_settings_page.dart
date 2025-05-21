import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/services/reminders/models/reminder_mode.dart';
import 'package:water_mind/src/core/services/reminders/models/standard_reminder_time.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';
import 'package:water_mind/src/core/services/reminders/reminder_service_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/profile/providers/profile_provider.dart';
import 'package:water_mind/src/pages/reminders/widgets/interval_selector.dart';
import 'package:water_mind/src/pages/reminders/widgets/premium_mode_card.dart';
import 'package:water_mind/src/pages/reminders/widgets/time_picker_bottom_sheet.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_feature_lock.dart';

/// Page for configuring water reminder settings
@RoutePage()
class ReminderSettingsPage extends ConsumerStatefulWidget {
  /// Constructor
  const ReminderSettingsPage({super.key});

  @override
  ConsumerState<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends ConsumerState<ReminderSettingsPage>
    with HapticFeedbackMixin {
  WaterReminderModel? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // No need for didUpdateWidget as we handle initialization in _loadSettings and _saveSettings

  void _initializeStandardTimes([bool showLoading = true]) {
    if (_settings == null) return;

    final standardTimes = generateStandardReminderTimes(
      _settings!.wakeUpTime,
      _settings!.bedTime,
    );

    // Save the generated times
    _saveSettings(_settings!.copyWith(standardTimes: standardTimes), showLoading: showLoading);
  }

  Future<void> _loadSettings() async {
    final reminderService = ref.read(reminderServiceProvider);
    final settings = await reminderService.getReminderSettings();

    setState(() {
      _settings = settings;
    });

    // Initialize times if needed
    if (_settings != null) {
      if (_settings!.mode == ReminderMode.standard && _settings!.standardTimes.isEmpty) {
        // Use post-frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeStandardTimes();
        });
      } else if (_settings!.mode == ReminderMode.custom && _settings!.customTimes.isEmpty) {
        // Use post-frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeCustomTimes();
        });
      }
    }
  }

  Future<void> _saveSettings(WaterReminderModel settings, {bool showLoading = false}) async {
    // Check if we're switching modes and need to initialize times
    final needsStandardTimesInit =
        _settings != null &&
        _settings!.mode != ReminderMode.standard &&
        settings.mode == ReminderMode.standard &&
        settings.standardTimes.isEmpty;

    final needsCustomTimesInit =
        _settings != null &&
        _settings!.mode != ReminderMode.custom &&
        settings.mode == ReminderMode.custom &&
        settings.customTimes.isEmpty;

    // Kiểm tra xem thời gian thức dậy hoặc đi ngủ có thay đổi không
    final wakeUpTimeChanged = _settings != null &&
        _settings!.wakeUpTime.hour != settings.wakeUpTime.hour ||
        _settings!.wakeUpTime.minute != settings.wakeUpTime.minute;

    final bedTimeChanged = _settings != null &&
        _settings!.bedTime.hour != settings.bedTime.hour ||
        _settings!.bedTime.minute != settings.bedTime.minute;

    // Lưu cài đặt mà không hiển thị loading
    final reminderService = ref.read(reminderServiceProvider);
    await reminderService.saveReminderSettings(settings);

    // Cập nhật state
    setState(() {
      _settings = settings;
    });

    // Đồng bộ hóa với profile settings nếu thời gian thay đổi
    if (wakeUpTimeChanged || bedTimeChanged) {
      final profileNotifier = ref.read(profileSettingsProvider.notifier);

      if (wakeUpTimeChanged) {
        // Chỉ cập nhật trong profile settings, không cần cập nhật lại reminder settings
        // vì đã được cập nhật ở trên
        profileNotifier.syncWakeUpTime(settings.wakeUpTime);
      }

      if (bedTimeChanged) {
        // Chỉ cập nhật trong profile settings, không cần cập nhật lại reminder settings
        // vì đã được cập nhật ở trên
        profileNotifier.syncBedTime(settings.bedTime);
      }
    }

    // Initialize times if we just switched modes
    if (needsStandardTimesInit) {
      _initializeStandardTimes(false);
    } else if (needsCustomTimesInit) {
      _initializeCustomTimes(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.router.maybePop(true)
        , icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: Text(
          context.l10n.reminders,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _settings == null
          ? const SizedBox.shrink() // Không hiển thị loading, chỉ hiển thị màn hình trống
          : _buildSettingsContent(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.thirdColor.withOpacity(0.8), // Ignore deprecation warning
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsContent() {
    if (_settings == null) {
      return const Center(child: Text('Error loading settings', style: TextStyle(color: Colors.white)));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // GENERAL SETTINGS SECTION
        _buildSectionTitle(context.l10n.settings),

        _buildSettingsCard([
          // Enable/disable reminders
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined, color: Colors.white),
            title: Text(
              context.l10n.enableReminders,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              context.l10n.enableRemindersDescription,
              style: const TextStyle(color: Colors.white70),
            ),
            value: _settings!.enabled,
            activeColor: Colors.white,
            activeTrackColor: AppColor.thirdColor,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              _saveSettings(_settings!.copyWith(enabled: value), showLoading: false);
            },
          ),
        ]),

        const SizedBox(height: 24),

        // REMINDER MODE SECTION
        _buildSectionTitle(context.l10n.reminderMode),

        _buildSettingsCard([
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.white),
            title: Text(
              context.l10n.reminderMode,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              _settings!.mode.getDescription(context),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ]),

        // Mode selection cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildModeSelectionCards(),
        ),

        // Mode-specific settings
        _buildSettingsCard([
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildModeSpecificSettings(),
          ),
        ]),

        const SizedBox(height: 24),

        // TIME SETTINGS SECTION
        _buildSectionTitle(context.l10n.timeSettings),

        _buildSettingsCard([
          // Wake up time
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
            title: Text(
              context.l10n.wakeUpTime,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_settings!.wakeUpTime.hour}:${_settings!.wakeUpTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () => _selectWakeUpTime(),
          ),

          // Bedtime
          ListTile(
            leading: const Icon(Icons.nightlight_outlined, color: Colors.white),
            title: Text(
              context.l10n.bedTime,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_settings!.bedTime.hour}:${_settings!.bedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () => _selectBedTime(),
          ),
        ]),

        const SizedBox(height: 24),

        // ADVANCED SETTINGS SECTION
        _buildSectionTitle(context.l10n.advancedSettings),

        _buildSettingsCard([
          // Skip if goal met
          SwitchListTile(
            secondary: const Icon(Icons.check_circle_outline, color: Colors.white),
            title: Text(
              context.l10n.skipIfGoalMet,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              context.l10n.skipIfGoalMetDescription,
              style: const TextStyle(color: Colors.white70),
            ),
            value: _settings!.skipIfGoalMet,
            activeColor: Colors.white,
            activeTrackColor: AppColor.thirdColor,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              _saveSettings(_settings!.copyWith(skipIfGoalMet: value), showLoading: false);
            },
          ),

          // Do not disturb
          SwitchListTile(
            secondary: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.white),
            title: Text(
              context.l10n.doNotDisturb,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              context.l10n.doNotDisturbDescription,
              style: const TextStyle(color: Colors.white70),
            ),
            value: _settings!.enableDoNotDisturb,
            activeColor: Colors.white,
            activeTrackColor: AppColor.thirdColor,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              // If enabling, make sure we have default values
              if (value && (_settings!.doNotDisturbStart == null || _settings!.doNotDisturbEnd == null)) {
                _saveSettings(_settings!.copyWith(
                  enableDoNotDisturb: value,
                  doNotDisturbStart: const TimeOfDay(hour: 22, minute: 0),
                  doNotDisturbEnd: const TimeOfDay(hour: 7, minute: 0),
                ), showLoading: false);
              } else {
                _saveSettings(_settings!.copyWith(enableDoNotDisturb: value), showLoading: false);
              }
            },
          ),

          // Do not disturb time range
          if (_settings!.enableDoNotDisturb) ...[
            ListTile(
              leading: const Icon(Icons.bedtime_outlined, color: Colors.white),
              title: Text(
                context.l10n.doNotDisturbStart,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_settings!.doNotDisturbStart?.hour ?? 22}:${(_settings!.doNotDisturbStart?.minute ?? 0).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
              onTap: () => _selectDoNotDisturbStart(),
            ),

            ListTile(
              leading: const Icon(Icons.alarm_outlined, color: Colors.white),
              title: Text(
                context.l10n.doNotDisturbEnd,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_settings!.doNotDisturbEnd?.hour ?? 7}:${(_settings!.doNotDisturbEnd?.minute ?? 0).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
              onTap: () => _selectDoNotDisturbEnd(),
            ),
          ],
        ]),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildModeSelectionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Standard mode card with premium check
          Expanded(
            child: PremiumModeCard(
              mode: ReminderMode.standard,
              icon: Icons.access_time,
              isSelected: _settings!.mode == ReminderMode.standard,
              onSelected: (mode) {
                _saveSettings(_settings!.copyWith(mode: mode), showLoading: true);
              },
            ),
          ),

          // Interval mode card with premium check
          Expanded(
            child: PremiumModeCard(
              mode: ReminderMode.interval,
              icon: Icons.timer,
              isSelected: _settings!.mode == ReminderMode.interval,
              onSelected: (mode) {
                _saveSettings(_settings!.copyWith(mode: mode), showLoading: true);
              },
            ),
          ),

          // Custom mode card with premium check
          Expanded(
            child: PremiumModeCard(
              mode: ReminderMode.custom,
              icon: Icons.edit_calendar,
              isSelected: _settings!.mode == ReminderMode.custom,
              onSelected: (mode) {
                _saveSettings(_settings!.copyWith(mode: mode), showLoading: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSpecificSettings() {
    switch (_settings!.mode) {
      case ReminderMode.standard:
        return _buildStandardModeSettings();
      case ReminderMode.interval:
        return _buildIntervalModeSettings();
      case ReminderMode.custom:
        return _buildCustomModeSettings();
    }
  }

  Widget _buildStandardModeSettings() {
    // Initialize standard times if empty without showing loading indicator
    if (_settings!.standardTimes.isEmpty) {
      // Create a placeholder time to show immediately
      setState(() {
        _settings = _settings!.copyWith(
          standardTimes: [
            const StandardReminderTime(
              id: 'placeholder_8_0',
              time: TimeOfDay(hour: 8, minute: 0),
              label: 'Morning',
              enabled: true,
            ),
            const StandardReminderTime(
              id: 'placeholder_12_0',
              time: TimeOfDay(hour: 12, minute: 0),
              label: 'Noon',
              enabled: true,
            ),
            const StandardReminderTime(
              id: 'placeholder_18_0',
              time: TimeOfDay(hour: 18, minute: 0),
              label: 'Evening',
              enabled: true,
            ),
          ],
        );
      });

      // Initialize proper times after frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeStandardTimes(false);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.standardModeDescription,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),

        // List of standard reminder times
        ...List.generate(_settings!.standardTimes.length, (index) {
          final reminderTime = _settings!.standardTimes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppColor.thirdColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: reminderTime.enabled ? AppColor.primaryColor : Colors.grey,
                foregroundColor: Colors.white,
                child: Icon(
                  _getReminderTimeIcon(reminderTime),
                  size: 20,
                ),
              ),
              title: Text(
                reminderTime.label ?? reminderTime.getFormattedTime(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                reminderTime.label != null ? reminderTime.getFormattedTime() : '',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle switch
                  Switch(
                    value: reminderTime.enabled,
                    activeColor: Colors.white,
                    activeTrackColor: AppColor.primaryColor,
                    onChanged: (value) {
                      haptic(HapticFeedbackType.selection);
                      _updateStandardReminderTime(
                        index,
                        reminderTime.copyWith(enabled: value),
                      );
                    },
                  ),

                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editStandardReminderTime(index),
                  ),
                ],
              ),
            ),
          );
        }),

        // Add button
        if (_settings!.standardTimes.length < 8)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  context.l10n.addTime,
                  style: const TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: _addStandardReminderTime,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getReminderTimeIcon(StandardReminderTime reminderTime) {
    final hour = reminderTime.time.hour;

    if (hour >= 5 && hour < 10) {
      return Icons.wb_sunny_outlined; // Morning
    } else if (hour >= 10 && hour < 14) {
      return Icons.wb_sunny; // Noon
    } else if (hour >= 14 && hour < 18) {
      return Icons.wb_twighlight; // Afternoon
    } else if (hour >= 18 && hour < 22) {
      return Icons.nights_stay_outlined; // Evening
    } else {
      return Icons.bedtime_outlined; // Night
    }
  }

  void _updateStandardReminderTime(int index, StandardReminderTime updatedTime) {
    final updatedTimes = List<StandardReminderTime>.from(_settings!.standardTimes);
    updatedTimes[index] = updatedTime;
    _saveSettings(_settings!.copyWith(standardTimes: updatedTimes), showLoading: false);
  }

  void _addStandardReminderTime() {
    // Find a time that's not already in the list
    final existingTimes = _settings!.standardTimes.map((t) => t.getTotalMinutes()).toSet();

    // Start with noon and find an available time
    int hour = 12;
    int minute = 0;

    while (existingTimes.contains(hour * 60 + minute) && hour < 22) {
      hour++;
    }

    if (existingTimes.contains(hour * 60 + minute)) {
      // Try different minutes if all hours are taken
      hour = 12;
      minute = 30;

      while (existingTimes.contains(hour * 60 + minute) && hour < 22) {
        hour++;
      }
    }

    final newTime = StandardReminderTime(
      id: 'standard_${DateTime.now().millisecondsSinceEpoch}',
      time: TimeOfDay(hour: hour, minute: minute),
      enabled: true,
    );

    final updatedTimes = List<StandardReminderTime>.from(_settings!.standardTimes)..add(newTime);

    // Sort by time
    updatedTimes.sort((a, b) => a.getTotalMinutes().compareTo(b.getTotalMinutes()));

    _saveSettings(_settings!.copyWith(standardTimes: updatedTimes));
  }

  void _editStandardReminderTime(int index) {
    final reminderTime = _settings!.standardTimes[index];

    TimePickerBottomSheet.show(
      context: context,
      initialTime: reminderTime.time,
      title: context.l10n.wakeUpTime, // Using wakeUpTime as a generic time title
      onSaved: (newTime) {
        // Check if this time already exists
        if (_settings!.standardTimes.any((t) =>
            t.time.hour == newTime.hour &&
            t.time.minute == newTime.minute &&
            t != reminderTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.timeAlreadyExists),
            ),
          );
          return;
        }

        // Update the time
        final updatedTime = reminderTime.copyWith(time: newTime);
        final updatedTimes = List<StandardReminderTime>.from(_settings!.standardTimes);
        updatedTimes[index] = updatedTime;

        // Sort by time
        updatedTimes.sort((a, b) => a.getTotalMinutes().compareTo(b.getTotalMinutes()));

        _saveSettings(_settings!.copyWith(standardTimes: updatedTimes), showLoading: false);
      },
    );
  }

  Widget _buildIntervalModeSettings() {
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.intervalModeDescription,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Interval selector with premium check
          isPremiumActiveAsync.when(
            data: (isPremiumActive) {
              if (isPremiumActive) {
                return _buildIntervalSelector();
              } else {
                return PremiumFeatureLock(
                  message: context.l10n.customReminderModeDesc,
                  child: _buildIntervalSelector(),
                );
              }
            },
            loading: () => _buildIntervalSelector(),
            error: (_, __) => _buildIntervalSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Theme(
      data: Theme.of(context).copyWith(
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.white,
          thumbColor: Colors.white,
          overlayColor: Colors.white.withOpacity(0.3),
          valueIndicatorColor: AppColor.primaryColor,
          valueIndicatorTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      child: IntervalSelector(
        initialValue: _settings!.intervalMinutes,
        onChanged: (value) {
          haptic(HapticFeedbackType.selection);

          // Check if premium is active
          final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
          if (isPremiumActive) {
            _saveSettings(_settings!.copyWith(intervalMinutes: value), showLoading: false);
          } else {
            // If not premium, show premium subscription page
            context.router.push(const PremiumSubscriptionRoute());
          }
        },
      ),
    );
  }

  Widget _buildCustomModeSettings() {
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);

    // Initialize custom times if empty without showing loading indicator
    if (_settings!.customTimes.isEmpty) {
      // Create placeholder times to show immediately
      setState(() {
        _settings = _settings!.copyWith(
          customTimes: [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 12, minute: 0),
            const TimeOfDay(hour: 16, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ],
          disabledCustomTimes: [],
        );
      });

      // Initialize proper times after frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeCustomTimes(false);
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.customModeDescription,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Custom times grid with premium check
          isPremiumActiveAsync.when(
            data: (isPremiumActive) {
              if (isPremiumActive) {
                return Column(
                  children: [
                    // Custom times grid
                    _buildCustomTimesGrid(),

                    // Help text
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                      child: Text(
                        context.l10n.tapToToggleHint,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return PremiumFeatureLock(
                  message: context.l10n.customReminderModeDesc,
                  child: Column(
                    children: [
                      // Custom times grid
                      _buildCustomTimesGrid(),

                      // Help text
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                        child: Text(
                          context.l10n.tapToToggleHint,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            loading: () => _buildCustomTimesGrid(),
            error: (_, __) => _buildCustomTimesGrid(),
          ),
        ],
      ),
    );
  }

  void _initializeCustomTimes([bool showLoading = true]) {
    // Create predefined times similar to the example image
    final List<TimeOfDay> customTimes = [
      const TimeOfDay(hour: 6, minute: 30),
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 9, minute: 30),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 12, minute: 30),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 30),
      const TimeOfDay(hour: 17, minute: 0),
      const TimeOfDay(hour: 18, minute: 30),
      const TimeOfDay(hour: 20, minute: 0),
      const TimeOfDay(hour: 21, minute: 30),
      const TimeOfDay(hour: 23, minute: 0),
    ];

    // Set the first and last times as disabled by default
    final List<TimeOfDay> disabledTimes = [
      const TimeOfDay(hour: 6, minute: 30),
      const TimeOfDay(hour: 23, minute: 0),
    ];

    // Save the custom times
    _saveSettings(_settings!.copyWith(
      customTimes: customTimes,
      disabledCustomTimes: disabledTimes,
    ), showLoading: showLoading);
  }

  Widget _buildCustomTimesGrid() {
    // Sort times
    final sortedTimes = List<TimeOfDay>.from(_settings!.customTimes);
    sortedTimes.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });

    // Calculate item width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final itemsPerRow = screenWidth > 400 ? 4 : 3;
    final itemWidth = (screenWidth - 48) / itemsPerRow; // 48 = padding + spacing

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection view using Wrap
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              ...List.generate(sortedTimes.length, (index) {
                return SizedBox(
                  width: itemWidth,
                  child: _buildTimeBox(sortedTimes[index], index),
                );
              }),
              // Add button at the end
              SizedBox(
                width: itemWidth,
                child: _buildAddTimeBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(TimeOfDay time, int index) {
    // Check if this time is enabled
    final isEnabled = !_isTimeDisabled(time);

    // Format time as HH:MM (24-hour format)
    final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _toggleTimeEnabled(index),
      onLongPress: () => _editCustomTime(index),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            formattedTime,
            style: TextStyle(
              color: isEnabled ? Colors.white : Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isTimeDisabled(TimeOfDay time) {
    // Check if this time is in the disabled list
    final disabledTimes = _settings!.disabledCustomTimes;
    return disabledTimes.any((t) => t.hour == time.hour && t.minute == time.minute);
  }

  void _toggleTimeEnabled(int index) {
    // Check if premium is active
    final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
    if (!isPremiumActive) {
      // If not premium, show premium subscription page
      context.router.push(const PremiumSubscriptionRoute());
      return;
    }

    final time = _settings!.customTimes[index];
    final disabledTimes = List<TimeOfDay>.from(_settings!.disabledCustomTimes);

    if (_isTimeDisabled(time)) {
      // Enable the time by removing it from disabled list
      disabledTimes.removeWhere((t) => t.hour == time.hour && t.minute == time.minute);
    } else {
      // Disable the time by adding it to disabled list
      disabledTimes.add(time);
    }

    // Save the updated settings without showing loading
    _saveSettings(_settings!.copyWith(disabledCustomTimes: disabledTimes), showLoading: false);

    // Provide haptic feedback
    haptic(HapticFeedbackType.selection);
  }

  Widget _buildAddTimeBox() {
    return GestureDetector(
      onTap: _addCustomTime,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.black54,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _editCustomTime(int index) {
    // Check if premium is active
    final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
    if (!isPremiumActive) {
      // If not premium, show premium subscription page
      context.router.push(const PremiumSubscriptionRoute());
      return;
    }

    final time = _settings!.customTimes[index];

    TimePickerBottomSheet.show(
      context: context,
      initialTime: time,
      title: context.l10n.customTimes,
      onSaved: (newTime) {
        // Check if this time already exists
        if (_settings!.customTimes.any((t) =>
            t.hour == newTime.hour &&
            t.minute == newTime.minute &&
            t != time)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.timeAlreadyExists),
            ),
          );
          return;
        }

        // Update the time
        final updatedTimes = List<TimeOfDay>.from(_settings!.customTimes);
        updatedTimes[index] = newTime;

        // Sort the times
        updatedTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });

        // Check if this time was disabled
        final wasDisabled = _isTimeDisabled(time);
        final disabledTimes = List<TimeOfDay>.from(_settings!.disabledCustomTimes);

        // Remove the old time from disabled list if it was there
        if (wasDisabled) {
          disabledTimes.removeWhere((t) => t.hour == time.hour && t.minute == time.minute);
          // Add the new time to disabled list to maintain state
          disabledTimes.add(newTime);
        }

        // Save without showing loading
        _saveSettings(_settings!.copyWith(
          customTimes: updatedTimes,
          disabledCustomTimes: disabledTimes,
        ), showLoading: false);

        // Provide haptic feedback
        haptic(HapticFeedbackType.selection);
      },
    );
  }

  // We no longer need the delete function as we're using enable/disable instead

  void _addCustomTime() {
    // Check if premium is active
    final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
    if (!isPremiumActive) {
      // If not premium, show premium subscription page
      context.router.push(const PremiumSubscriptionRoute());
      return;
    }

    // Don't allow more than 24 times (one for each hour)
    if (_settings!.customTimes.length >= 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.maxTimesReached),
        ),
      );
      return;
    }

    // Show time picker with current time as default
    final now = TimeOfDay.now();

    // Round to nearest 5 minutes for better UX
    final minute = (now.minute / 5).round() * 5;
    final initialTime = TimeOfDay(
      hour: now.hour,
      minute: minute >= 60 ? 0 : minute,
    );

    // Show time picker
    TimePickerBottomSheet.show(
      context: context,
      initialTime: initialTime,
      title: context.l10n.addTime,
      onSaved: (newTime) {
        // Check if this time already exists
        if (_settings!.customTimes.any((t) =>
            t.hour == newTime.hour &&
            t.minute == newTime.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.timeAlreadyExists),
            ),
          );
          return;
        }

        // Add the new time
        final updatedTimes = List<TimeOfDay>.from(_settings!.customTimes)..add(newTime);

        // Sort the times
        updatedTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });

        // Save without showing loading
        _saveSettings(_settings!.copyWith(customTimes: updatedTimes), showLoading: false);

        // Provide haptic feedback
        haptic(HapticFeedbackType.selection);
      },
    );
  }

  void _selectWakeUpTime() {
    TimePickerBottomSheet.show(
      context: context,
      initialTime: _settings!.wakeUpTime,
      title: context.l10n.wakeUpTime,
      onSaved: (picked) {
        haptic(HapticFeedbackType.success);
        _saveSettings(_settings!.copyWith(wakeUpTime: picked), showLoading: false);
      },
    );
  }

  void _selectBedTime() {
    TimePickerBottomSheet.show(
      context: context,
      initialTime: _settings!.bedTime,
      title: context.l10n.bedTime,
      onSaved: (picked) {
        haptic(HapticFeedbackType.success);
        _saveSettings(_settings!.copyWith(bedTime: picked), showLoading: false);
      },
    );
  }

  void _selectDoNotDisturbStart() {
    TimePickerBottomSheet.show(
      context: context,
      initialTime: _settings!.doNotDisturbStart ?? const TimeOfDay(hour: 22, minute: 0),
      title: context.l10n.doNotDisturbStart,
      onSaved: (picked) {
        haptic(HapticFeedbackType.success);
        _saveSettings(_settings!.copyWith(doNotDisturbStart: picked), showLoading: false);
      },
    );
  }

  void _selectDoNotDisturbEnd() {
    TimePickerBottomSheet.show(
      context: context,
      initialTime: _settings!.doNotDisturbEnd ?? const TimeOfDay(hour: 7, minute: 0),
      title: context.l10n.doNotDisturbEnd,
      onSaved: (picked) {
        haptic(HapticFeedbackType.success);
        _saveSettings(_settings!.copyWith(doNotDisturbEnd: picked), showLoading: false);
      },
    );
  }
}
