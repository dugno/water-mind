import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/reminders/models/reminder_mode.dart';
import 'package:water_mind/src/core/services/reminders/models/water_reminder_model.dart';
import 'package:water_mind/src/core/services/reminders/reminder_service_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/reminders/widgets/custom_time_picker.dart';
import 'package:water_mind/src/pages/reminders/widgets/interval_selector.dart';
import 'package:water_mind/src/pages/reminders/widgets/time_of_day_picker.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final reminderService = ref.read(reminderServiceProvider);
    final settings = await reminderService.getReminderSettings();
    
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings(WaterReminderModel settings) async {
    setState(() {
      _isLoading = true;
    });
    
    final reminderService = ref.read(reminderServiceProvider);
    await reminderService.saveReminderSettings(settings);
    
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reminders),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    if (_settings == null) {
      return const Center(child: Text('Error loading settings'));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Enable/disable reminders
        SwitchListTile(
          title: Text(context.l10n.enableReminders),
          subtitle: Text(context.l10n.enableRemindersDescription),
          value: _settings!.enabled,
          onChanged: (value) {
            haptic(HapticFeedbackType.selection);
            _saveSettings(_settings!.copyWith(enabled: value));
          },
        ),
        
        const Divider(),
        
        // Reminder mode selector
        ListTile(
          title: Text(context.l10n.reminderMode),
          subtitle: Text(_settings!.mode.description),
        ),
        
        // Mode selection cards
        _buildModeSelectionCards(),
        
        const Divider(),
        
        // Mode-specific settings
        _buildModeSpecificSettings(),
        
        const Divider(),
        
        // Wake up and bedtime settings
        ListTile(
          title: Text(context.l10n.wakeUpAndBedtime),
          subtitle: Text(context.l10n.wakeUpAndBedtimeDescription),
        ),
        
        // Wake up time
        ListTile(
          title: Text(context.l10n.wakeUpTime),
          trailing: TextButton(
            onPressed: () => _selectWakeUpTime(),
            child: Text(
              '${_settings!.wakeUpTime.hour}:${_settings!.wakeUpTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        
        // Bedtime
        ListTile(
          title: Text(context.l10n.bedTime),
          trailing: TextButton(
            onPressed: () => _selectBedTime(),
            child: Text(
              '${_settings!.bedTime.hour}:${_settings!.bedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        
        const Divider(),
        
        // Advanced settings
        ExpansionTile(
          title: Text(context.l10n.advancedSettings),
          children: [
            // Skip if goal met
            SwitchListTile(
              title: Text(context.l10n.skipIfGoalMet),
              subtitle: Text(context.l10n.skipIfGoalMetDescription),
              value: _settings!.skipIfGoalMet,
              onChanged: (value) {
                haptic(HapticFeedbackType.selection);
                _saveSettings(_settings!.copyWith(skipIfGoalMet: value));
              },
            ),
            
            // Do not disturb
            SwitchListTile(
              title: Text(context.l10n.doNotDisturb),
              subtitle: Text(context.l10n.doNotDisturbDescription),
              value: _settings!.enableDoNotDisturb,
              onChanged: (value) {
                haptic(HapticFeedbackType.selection);
                _saveSettings(_settings!.copyWith(enableDoNotDisturb: value));
                
                // If enabling, make sure we have default values
                if (value && (_settings!.doNotDisturbStart == null || _settings!.doNotDisturbEnd == null)) {
                  _saveSettings(_settings!.copyWith(
                    doNotDisturbStart: const TimeOfDay(hour: 22, minute: 0),
                    doNotDisturbEnd: const TimeOfDay(hour: 7, minute: 0),
                  ));
                }
              },
            ),
            
            // Do not disturb time range
            if (_settings!.enableDoNotDisturb) ...[
              ListTile(
                title: Text(context.l10n.doNotDisturbStart),
                trailing: TextButton(
                  onPressed: () => _selectDoNotDisturbStart(),
                  child: Text(
                    '${_settings!.doNotDisturbStart?.hour ?? 22}:${(_settings!.doNotDisturbStart?.minute ?? 0).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              ListTile(
                title: Text(context.l10n.doNotDisturbEnd),
                trailing: TextButton(
                  onPressed: () => _selectDoNotDisturbEnd(),
                  child: Text(
                    '${_settings!.doNotDisturbEnd?.hour ?? 7}:${(_settings!.doNotDisturbEnd?.minute ?? 0).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildModeSelectionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Standard mode card
          Expanded(
            child: _buildModeCard(
              mode: ReminderMode.standard,
              icon: Icons.access_time,
            ),
          ),
          
          // Interval mode card
          Expanded(
            child: _buildModeCard(
              mode: ReminderMode.interval,
              icon: Icons.timer,
            ),
          ),
          
          // Custom mode card
          Expanded(
            child: _buildModeCard(
              mode: ReminderMode.custom,
              icon: Icons.edit_calendar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required ReminderMode mode,
    required IconData icon,
  }) {
    final isSelected = _settings!.mode == mode;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () {
          haptic(HapticFeedbackType.selection);
          _saveSettings(_settings!.copyWith(mode: mode));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(height: 8),
              Text(
                mode.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        context.l10n.standardModeDescription,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildIntervalModeSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.intervalModeDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          IntervalSelector(
            initialValue: _settings!.intervalMinutes,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              _saveSettings(_settings!.copyWith(intervalMinutes: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomModeSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.customModeDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          CustomTimePicker(
            times: _settings!.customTimes,
            onTimesChanged: (times) {
              haptic(HapticFeedbackType.selection);
              _saveSettings(_settings!.copyWith(customTimes: times));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: _settings!.wakeUpTime,
    );
    
    if (picked != null && context.mounted) {
      haptic(HapticFeedbackType.selection);
      _saveSettings(_settings!.copyWith(wakeUpTime: picked));
    }
  }

  Future<void> _selectBedTime() async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: _settings!.bedTime,
    );
    
    if (picked != null && context.mounted) {
      haptic(HapticFeedbackType.selection);
      _saveSettings(_settings!.copyWith(bedTime: picked));
    }
  }

  Future<void> _selectDoNotDisturbStart() async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: _settings!.doNotDisturbStart ?? const TimeOfDay(hour: 22, minute: 0),
    );
    
    if (picked != null && context.mounted) {
      haptic(HapticFeedbackType.selection);
      _saveSettings(_settings!.copyWith(doNotDisturbStart: picked));
    }
  }

  Future<void> _selectDoNotDisturbEnd() async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: _settings!.doNotDisturbEnd ?? const TimeOfDay(hour: 7, minute: 0),
    );
    
    if (picked != null && context.mounted) {
      haptic(HapticFeedbackType.selection);
      _saveSettings(_settings!.copyWith(doNotDisturbEnd: picked));
    }
  }
}
