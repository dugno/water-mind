import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
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
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        title: Text(
          context.l10n.profile,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileSettingsAsync.when(
        data: (settings) => _buildProfileContent(settings),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, stack) => Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(ProfileSettingsModel profileSettings) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // REMINDER SETTINGS SECTION
        _buildSectionTitle(context.l10n.reminders),

        _buildSettingsCard([
          // Reminder Settings
          ListTile(
            leading: const Icon(Icons.access_alarm, color: Colors.white),
            title: Text(
              context.l10n.reminderSettings,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Standard Mode',
              style: TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              context.router.push(const ReminderSettingsRoute());
            },
          ),

          // Sound
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined, color: Colors.white),
            title: Text(
              context.l10n.enableSound,
              style: const TextStyle(color: Colors.white),
            ),
            value: profileSettings.soundEnabled,
            activeColor: Colors.white,
            activeTrackColor: AppColor.thirdColor,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              ref.read(profileSettingsProvider.notifier).updateSoundEnabled(value);
            },
          ),

          // Vibration
          SwitchListTile(
            secondary: const Icon(Icons.vibration, color: Colors.white),
            title: Text(
              context.l10n.enableVibration,
              style: const TextStyle(color: Colors.white),
            ),
            value: profileSettings.vibrationEnabled,
            activeColor: Colors.white,
            activeTrackColor: AppColor.thirdColor,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              ref.read(profileSettingsProvider.notifier).updateVibrationEnabled(value);
            },
          ),
        ]),

        const SizedBox(height: 24),

        // DRINK SECTION
        _buildSectionTitle('Drink'),

        _buildSettingsCard([
          // Daily Goal
          ListTile(
            leading: const Icon(Icons.water_drop_outlined, color: Colors.white),
            title: Text(
              context.l10n.dailyGoal,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${profileSettings.customDailyGoal?.toInt() ?? 2500} ${profileSettings.measureUnit == MeasureUnit.metric ? 'ml' : 'oz'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showDailyGoalDialog(profileSettings);
            },
          ),

          // Custom Daily Goal Switch
          SwitchListTile(
            secondary: const Icon(Icons.edit, color: Colors.white),
            title: Text(
              context.l10n.useCustomDailyGoal,
              style: const TextStyle(color: Colors.white),
            ),
            value: profileSettings.useCustomDailyGoal,
            activeColor: Colors.white,
            activeTrackColor: AppColor.thirdColor,
            onChanged: (value) {
              haptic(HapticFeedbackType.selection);
              ref.read(profileSettingsProvider.notifier).updateDailyGoal(
                profileSettings.customDailyGoal ?? 2500,
                value,
              );
            },
          ),

          // Physical Attributes
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: const Text(
              'Physical Attributes',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showPhysicalAttributesDialog(profileSettings);
            },
          ),

          // Gender
          ListTile(
            leading: Icon(_getGenderIcon(profileSettings.gender), color: Colors.white),
            title: Text(
              context.l10n.gender,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileSettings.gender?.getString(context) ?? context.l10n.notSet,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showPhysicalAttributesDialog(profileSettings);
            },
          ),

          // Weight
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined, color: Colors.white),
            title: Text(
              context.l10n.weight,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileSettings.weight != null
                      ? '${profileSettings.weight!.toStringAsFixed(1)} ${profileSettings.measureUnit == MeasureUnit.metric ? 'kg' : 'lb'}'
                      : context.l10n.notSet,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showPhysicalAttributesDialog(profileSettings);
            },
          ),

          // Height
          ListTile(
            leading: const Icon(Icons.straighten_outlined, color: Colors.white),
            title: Text(
              context.l10n.height,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileSettings.height != null
                      ? '${profileSettings.height!.toStringAsFixed(1)} ${profileSettings.measureUnit == MeasureUnit.metric ? 'cm' : 'in'}'
                      : context.l10n.notSet,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showPhysicalAttributesDialog(profileSettings);
            },
          ),
        ]),

        const SizedBox(height: 24),

        // GENERAL SECTION
        _buildSectionTitle('General'),

        _buildSettingsCard([
          // Units
          ListTile(
            leading: const Icon(Icons.straighten_outlined, color: Colors.white),
            title: Text(
              context.l10n.units,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileSettings.measureUnit == MeasureUnit.metric ? 'ml, kg' : 'oz, lb',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showUnitSelectorDialog(profileSettings);
            },
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language_outlined, color: Colors.white),
            title: Text(
              context.l10n.language,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getLanguageFlag(profileSettings.language),
                const SizedBox(width: 8),
                Text(
                  _getLanguageName(profileSettings.language),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showLanguageSelector(profileSettings);
            },
          ),

          // Time settings
          ListTile(
            leading: const Icon(Icons.access_time_outlined, color: Colors.white),
            title: Text(
              context.l10n.timeSettings,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _showTimeSettingsDialog(profileSettings);
            },
          ),

          // Feedback
          ListTile(
            leading: const Icon(Icons.feedback_outlined, color: Colors.white),
            title: Text(
              context.l10n.sendFeedback,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              // TODO: Implement feedback functionality
            },
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white),
            title: Text(
              context.l10n.privacyPolicy,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              // TODO: Implement privacy policy
            },
          ),

          // Share App
          ListTile(
            leading: const Icon(Icons.share_outlined, color: Colors.white),
            title: Text(
              context.l10n.shareApp,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              _shareApp();
            },
          ),

          // About App
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text(
              context.l10n.aboutApp,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              haptic(HapticFeedbackType.selection);
              // TODO: Implement about app
            },
          ),
        ]),

        const SizedBox(height: 32),
      ],
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
        color: AppColor.thirdColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showUnitSelectorDialog(ProfileSettingsModel profileSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.thirdColor,
        title: Text(
          context.l10n.units,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                context.l10n.measurementUnit,
                style: const TextStyle(color: Colors.white),
              ),
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
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeSettingsDialog(ProfileSettingsModel profileSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.thirdColor,
        title: Text(
          context.l10n.timeSettings,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                context.l10n.wakeUpTime,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: TextButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimeOfDayPicker(
                    context: context,
                    initialTime: profileSettings.wakeUpTime ?? const TimeOfDay(hour: 7, minute: 0),
                  );

                  if (picked != null && context.mounted) {
                    haptic(HapticFeedbackType.selection);
                    ref.read(profileSettingsProvider.notifier).updateWakeUpTime(picked);
                  }
                },
                child: Text(
                  profileSettings.wakeUpTime != null
                      ? '${profileSettings.wakeUpTime!.hour}:${profileSettings.wakeUpTime!.minute.toString().padLeft(2, '0')}'
                      : '7:00',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            ListTile(
              title: Text(
                context.l10n.bedTime,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: TextButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimeOfDayPicker(
                    context: context,
                    initialTime: profileSettings.bedTime ?? const TimeOfDay(hour: 23, minute: 0),
                  );

                  if (picked != null && context.mounted) {
                    haptic(HapticFeedbackType.selection);
                    ref.read(profileSettingsProvider.notifier).updateBedTime(picked);
                  }
                },
                child: Text(
                  profileSettings.bedTime != null
                      ? '${profileSettings.bedTime!.hour}:${profileSettings.bedTime!.minute.toString().padLeft(2, '0')}'
                      : '23:00',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
