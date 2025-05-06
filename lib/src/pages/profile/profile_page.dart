import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/profile/providers/profile_provider.dart';
import 'package:water_mind/src/pages/profile/widgets/daily_goal_dialog.dart';
import 'package:water_mind/src/pages/profile/widgets/language_selector.dart';
import 'package:water_mind/src/pages/profile/widgets/physical_attributes_dialog.dart';
import 'package:water_mind/src/pages/reminders/widgets/time_of_day_picker.dart';

import 'models/profile_settings_model.dart';

/// Profile page for the app
@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  /// Constructor
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with HapticFeedbackMixin {
  @override
  Widget build(BuildContext context) {
    final profileSettingsAsync = ref.watch(profileSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
      ),
      body: profileSettingsAsync.when(
        data: (settings) => _buildProfileContent(settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }

  Widget _buildProfileContent( ProfileSettingsModel profileSettings) {
    return ListView(
      children: [
        // User info card
        _buildUserInfoCard(profileSettings),

        const SizedBox(height: 16),

        // Reminders section
        _buildSection(
          title: context.l10n.reminders,
          icon: Icons.notifications_outlined,
          children: [
            ListTile(
              leading: const Icon(Icons.access_alarm),
              title: Text(context.l10n.reminderSettings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                context.router.push(const ReminderSettingsRoute());
              },
            ),
          ],
        ),

        // Daily goal section
        _buildSection(
          title: context.l10n.dailyGoal,
          icon: Icons.water_drop_outlined,
          children: [
            SwitchListTile(
              title: Text(context.l10n.useCustomDailyGoal),
              value: profileSettings.useCustomDailyGoal,
              onChanged: (value) {
                haptic(HapticFeedbackType.selection);
                ref.read(profileSettingsProvider.notifier).updateDailyGoal(
                  profileSettings.customDailyGoal ?? 2500,
                  value,
                );
              },
            ),
            ListTile(
              title: Text(context.l10n.setDailyGoal),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${profileSettings.customDailyGoal?.toInt() ?? 2500} ${profileSettings.measureUnit == MeasureUnit.metric ? 'ml' : 'oz'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              enabled: profileSettings.useCustomDailyGoal,
              onTap: profileSettings.useCustomDailyGoal ? () {
                haptic(HapticFeedbackType.selection);
                _showDailyGoalDialog(profileSettings);
              } : null,
            ),
          ],
        ),

        // Sound and vibration section
        _buildSection(
          title: context.l10n.soundAndVibration,
          icon: Icons.volume_up_outlined,
          children: [
            SwitchListTile(
              title: Text(context.l10n.enableSound),
              value: profileSettings.soundEnabled,
              onChanged: (value) {
                haptic(HapticFeedbackType.selection);
                ref.read(profileSettingsProvider.notifier).updateSoundEnabled(value);
              },
            ),
            SwitchListTile(
              title: Text(context.l10n.enableVibration),
              value: profileSettings.vibrationEnabled,
              onChanged: (value) {
                haptic(HapticFeedbackType.selection);
                ref.read(profileSettingsProvider.notifier).updateVibrationEnabled(value);
              },
            ),
          ],
        ),

        // Units section
        _buildSection(
          title: context.l10n.units,
          icon: Icons.straighten_outlined,
          children: [
            ListTile(
              title: Text(context.l10n.measurementUnit),
              trailing: SegmentedButton<MeasureUnit>(
                segments: [
                  ButtonSegment<MeasureUnit>(
                    value: MeasureUnit.metric,
                    label: Text(context.l10n.metric),
                  ),
                  ButtonSegment<MeasureUnit>(
                    value: MeasureUnit.imperial,
                    label: Text(context.l10n.imperial),
                  ),
                ],
                selected: {profileSettings.measureUnit},
                onSelectionChanged: (Set<MeasureUnit> selection) {
                  haptic(HapticFeedbackType.selection);
                  if (selection.isNotEmpty) {
                    ref.read(profileSettingsProvider.notifier).updateHeightWeight(
                      profileSettings.height ?? 170,
                      profileSettings.weight ?? 70,
                      selection.first,
                    );
                  }
                },
              ),
            ),
          ],
        ),

        // Physical attributes section
        _buildSection(
          title: context.l10n.physicalAttributes,
          icon: Icons.person_outline,
          children: [
            // Gender row
            ListTile(
              leading: Icon(_getGenderIcon(profileSettings.gender)),
              title: Text(context.l10n.gender),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profileSettings.gender?.getString(context) ?? context.l10n.notSet,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                _showPhysicalAttributesDialog(profileSettings);
              },
            ),

            // Weight row
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: Text(context.l10n.weight),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profileSettings.weight != null
                        ? '${profileSettings.weight!.toStringAsFixed(1)} ${profileSettings.measureUnit == MeasureUnit.metric ? 'kg' : 'lb'}'
                        : context.l10n.notSet,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                _showPhysicalAttributesDialog(profileSettings);
              },
            ),

            // Height row
            ListTile(
              leading: const Icon(Icons.straighten_outlined),
              title: Text(context.l10n.height),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profileSettings.height != null
                        ? '${profileSettings.height!.toStringAsFixed(1)} ${profileSettings.measureUnit == MeasureUnit.metric ? 'cm' : 'in'}'
                        : context.l10n.notSet,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                _showPhysicalAttributesDialog(profileSettings);
              },
            ),
          ],
        ),

        // Language section
        _buildSection(
          title: context.l10n.language,
          icon: Icons.language_outlined,
          children: [
            ListTile(
              title: Text(context.l10n.changeLanguage),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getLanguageFlag(profileSettings.language),
                  const SizedBox(width: 8),
                  Text(_getLanguageName(profileSettings.language)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                _showLanguageSelector(profileSettings);
              },
            ),
          ],
        ),

        // Time settings section
        _buildSection(
          title: context.l10n.timeSettings,
          icon: Icons.access_time_outlined,
          children: [
            ListTile(
              title: Text(context.l10n.wakeUpTime),
              trailing: TextButton(
                onPressed: () => _selectWakeUpTime(profileSettings),
                child: Text(
                  profileSettings.wakeUpTime != null
                      ? '${profileSettings.wakeUpTime!.hour}:${profileSettings.wakeUpTime!.minute.toString().padLeft(2, '0')}'
                      : '7:00',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            ListTile(
              title: Text(context.l10n.bedTime),
              trailing: TextButton(
                onPressed: () => _selectBedTime(profileSettings),
                child: Text(
                  profileSettings.bedTime != null
                      ? '${profileSettings.bedTime!.hour}:${profileSettings.bedTime!.minute.toString().padLeft(2, '0')}'
                      : '23:00',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),

        // About section
        _buildSection(
          title: context.l10n.about,
          icon: Icons.info_outline,
          children: [
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(context.l10n.sendFeedback),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                // TODO: Implement feedback functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(context.l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                // TODO: Implement privacy policy
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(context.l10n.shareApp),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                _shareApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.l10n.aboutApp),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                // TODO: Implement about app
              },
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildUserInfoCard(ProfileSettingsModel profileSettings) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getGenderIcon(profileSettings.gender),
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.yourProfile,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileSettings.gender != null
                        ? profileSettings.gender!.getString(context)
                        : context.l10n.tapToEdit,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Future<void> _selectWakeUpTime(ProfileSettingsModel profileSettings) async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: profileSettings.wakeUpTime ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (picked != null && context.mounted) {
      haptic(HapticFeedbackType.selection);
      ref.read(profileSettingsProvider.notifier).updateWakeUpTime(picked);
    }
  }

  Future<void> _selectBedTime(ProfileSettingsModel profileSettings) async {
    final TimeOfDay? picked = await showTimeOfDayPicker(
      context: context,
      initialTime: profileSettings.bedTime ?? const TimeOfDay(hour: 23, minute: 0),
    );

    if (picked != null && context.mounted) {
      haptic(HapticFeedbackType.selection);
      ref.read(profileSettingsProvider.notifier).updateBedTime(picked);
    }
  }

  void _showDailyGoalDialog(ProfileSettingsModel profileSettings) {
    showDialog(
      context: context,
      builder: (context) => DailyGoalDialog(
        initialValue: profileSettings.customDailyGoal?.toInt() ?? 2500,
        measureUnit: profileSettings.measureUnit,
        onSaved: (value) {
          ref.read(profileSettingsProvider.notifier).updateDailyGoal(
            value.toDouble(),
            true,
          );
        },
      ),
    );
  }

  void _showPhysicalAttributesDialog(ProfileSettingsModel profileSettings) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: PhysicalAttributesDialog(
            initialGender: profileSettings.gender,
            initialHeight: profileSettings.height,
            initialWeight: profileSettings.weight,
            measureUnit: profileSettings.measureUnit,
            onSaved: (gender, height, weight) {
              haptic(HapticFeedbackType.success);
              ref.read(profileSettingsProvider.notifier).updateGender(gender);
              ref.read(profileSettingsProvider.notifier).updateHeightWeight(
                height,
                weight,
                profileSettings.measureUnit,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(ProfileSettingsModel profileSettings) {
    showDialog(
      context: context,
      builder: (context) => LanguageSelector(
        currentLanguage: profileSettings.language,
        onLanguageSelected: (languageCode) {
          ref.read(profileSettingsProvider.notifier).updateLanguage(languageCode);
        },
      ),
    );
  }

  Widget _getLanguageFlag(String languageCode) {
    String flagAsset;
    switch (languageCode) {
      case 'en':
        flagAsset = 'assets/images/language/united_kingdom.png';
        break;
      case 'vi':
        flagAsset = 'assets/images/language/vietnam.png';
        break;
      case 'ja':
        flagAsset = 'assets/images/language/japan.png';
        break;
      case 'zh':
        flagAsset = 'assets/images/language/china.png';
        break;
      case 'ro':
        flagAsset = 'assets/images/language/romania.png';
        break;
      default:
        flagAsset = 'assets/images/language/united_kingdom.png';
    }

    return Image.asset(
      flagAsset,
      width: 24,
      height: 16,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.language, size: 24);
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'ro':
        return 'Română';
      default:
        return 'English';
    }
  }

  IconData _getGenderIcon(Gender? gender) {
    if (gender == null) return Icons.person;

    switch (gender) {
      case Gender.male:
        return Icons.male;
      case Gender.female:
        return Icons.female;
      case Gender.pregnant:
        return Icons.pregnant_woman;
      case Gender.breastfeeding:
        return Icons.child_care;
      case Gender.other:
        return Icons.person;
    }
  }

  void _shareApp() {
    Share.share(
      'Check out Water Mind app for tracking your daily water intake!',
      subject: 'Water Mind App',
    );
  }
}
