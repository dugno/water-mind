import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/reminders/models/reminder_mode.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/profile/models/profile_settings_model.dart';
import 'package:water_mind/src/pages/profile/providers/profile_provider.dart';
import 'package:water_mind/src/pages/profile/widgets/feedback_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/gender_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/height_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/language_selector_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/premium_daily_goal_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/premium_status_widget.dart';
import 'package:water_mind/src/pages/profile/widgets/time_settings_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/unit_selector_bottom_sheet.dart';
import 'package:water_mind/src/pages/profile/widgets/weight_bottom_sheet.dart';

import 'package:water_mind/src/ui/widgets/profile/stats_row_widget.dart';

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
        // Streak và tổng lượng nước đã uống
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: StatsRowWidget(),
        ),

        const SizedBox(height: 16),
        const PremiumStatusWidget(),
        const SizedBox(height: 16),
        _buildSettingsCard([
          ref.watch(reminderSettingsProvider).when(
            data: (settings) {
              final mode = settings?.mode ?? ReminderMode.standard;
              return ListTile(
                leading: const Icon(Icons.access_alarm, color: Colors.white),
                title: Text(
                  context.l10n.reminderSettings,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  mode.getName(context),
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {
                  haptic(HapticFeedbackType.selection);
                  context.router.push(const ReminderSettingsRoute()).then((value) {
                    if (value == true) {
                      ref.invalidate(reminderSettingsProvider);
                    }
                  });
                },
              );
            },
            loading: () => ListTile(
              leading: const Icon(Icons.access_alarm, color: Colors.white),
              title: Text(
                context.l10n.reminderSettings,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Loading...',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
            ),
            error: (_, __) => ListTile(
              leading: const Icon(Icons.access_alarm, color: Colors.white),
              title: Text(
                context.l10n.reminderSettings,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                context.l10n.standardMode,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                haptic(HapticFeedbackType.selection);
                context.router.push(const ReminderSettingsRoute()).then((value) {
                  if (value == true) {
                    ref.invalidate(reminderSettingsProvider);
                  }
                  setState(() {});
                });
              },
            ),
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




        _buildSettingsCard([
          // Daily Goal with premium indicator
          ListTile(
            leading: const Icon(Icons.water_drop_outlined, color: Colors.white),
            title: Row(
              children: [
                Text(
                  context.l10n.dailyGoal,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),

              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDailyGoal(profileSettings),
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
              _showGenderBottomSheet(profileSettings);
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
              _showWeightBottomSheet(profileSettings);
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
              _showHeightBottomSheet(profileSettings);
            },
          ),
        ]),

        const SizedBox(height: 24),


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
              FeedbackBottomSheet.show(context: context);
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
              context.router.push( PrivacyPolicyRoute());
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
              context.router.push(const AboutRoute());
            },
          ),
        ]),

        const SizedBox(height: 32),
      ],
    );
  }
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.thirdColor.withAlpha(204), // 0.8 * 255 = 204
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showUnitSelectorDialog(ProfileSettingsModel profileSettings) {
    UnitSelectorBottomSheet.show(
      context: context,
      measureUnit: profileSettings.measureUnit,
      onUnitChanged: (selectedUnit) {
        haptic(HapticFeedbackType.success);

        // Cập nhật chiều cao và cân nặng
        ref.read(profileSettingsProvider.notifier).updateHeightWeight(
          profileSettings.height ?? 170,
          profileSettings.weight ?? 70,
          selectedUnit,
        );

        // Không cần cập nhật mục tiêu uống nước hàng ngày ở đây
        // Đã được xử lý trong phương thức updateHeightWeight

        // Kích hoạt rebuild UI
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _showTimeSettingsDialog(ProfileSettingsModel profileSettings) {
    TimeSettingsBottomSheet.show(
      context: context,
      initialWakeUpTime: profileSettings.wakeUpTime ?? const TimeOfDay(hour: 7, minute: 0),
      initialBedTime: profileSettings.bedTime ?? const TimeOfDay(hour: 23, minute: 0),
      onSaved: (wakeUpTime, bedTime) {
        haptic(HapticFeedbackType.success);
        ref.read(profileSettingsProvider.notifier).updateWakeUpTime(wakeUpTime);
        ref.read(profileSettingsProvider.notifier).updateBedTime(bedTime);
      },
    );
  }

  void _showDailyGoalDialog(ProfileSettingsModel profileSettings) {
    // Use premium daily goal bottom sheet
    PremiumDailyGoalBottomSheet.show(
      context: context,
      initialValue: profileSettings.customDailyGoal?.toInt() ?? 2500,
      measureUnit: profileSettings.measureUnit,
      onSaved: (value) {
        haptic(HapticFeedbackType.success);
        ref.read(profileSettingsProvider.notifier).updateDailyGoal(
          value.toDouble(),
          false, // Không sử dụng useCustomDailyGoal nữa
        );
      },
    );
  }

  void _showGenderBottomSheet(ProfileSettingsModel profileSettings) {
    GenderBottomSheet.show(
      context: context,
      initialGender: profileSettings.gender,
      onSaved: (gender) {
        haptic(HapticFeedbackType.success);
        ref.read(profileSettingsProvider.notifier).updateGender(gender);
      },
    );
  }

  void _showHeightBottomSheet(ProfileSettingsModel profileSettings) {
    HeightBottomSheet.show(
      context: context,
      initialHeight: profileSettings.height,
      measureUnit: profileSettings.measureUnit,
      onSaved: (height) {
        haptic(HapticFeedbackType.success);
        ref.read(profileSettingsProvider.notifier).updateHeightWeight(
          height,
          profileSettings.weight ?? 70,
          profileSettings.measureUnit,
        );
      },
    );
  }

  void _showWeightBottomSheet(ProfileSettingsModel profileSettings) {
    WeightBottomSheet.show(
      context: context,
      initialWeight: profileSettings.weight,
      measureUnit: profileSettings.measureUnit,
      onSaved: (weight) {
        haptic(HapticFeedbackType.success);
        ref.read(profileSettingsProvider.notifier).updateHeightWeight(
          profileSettings.height ?? 170,
          weight,
          profileSettings.measureUnit,
        );
      },
    );
  }

  void _showLanguageSelector(ProfileSettingsModel profileSettings) {
    LanguageSelectorBottomSheet.show(
      context: context,
      currentLanguage: profileSettings.language,
      onLanguageSelected: (languageCode) {
        // Cập nhật ngôn ngữ trong profile settings và locale
        ref.read(profileSettingsProvider.notifier).updateLanguage(languageCode, ref: ref);
        if (mounted) {
          setState(() {
            // Kích hoạt rebuild để cập nhật ListTile Language
          });
        }
      },
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
    // Use share_plus package to share the app
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out Water Mind app for tracking your daily water intake!',
        subject: 'Water Mind App',
      ),
    );
  }

  /// Định dạng giá trị mục tiêu uống nước hàng ngày với đơn vị đo phù hợp
  String _formatDailyGoal(ProfileSettingsModel profileSettings) {
    final dailyGoal = profileSettings.customDailyGoal?.toInt() ?? 2500;

    if (profileSettings.measureUnit == MeasureUnit.metric) {
      // Nếu đơn vị là metric, hiển thị giá trị ml
      return '$dailyGoal ml';
    } else {
      // Nếu đơn vị là imperial, chuyển đổi từ ml sang fl oz
      // 1 ml ≈ 0.033814 fl oz
      final flOz = (dailyGoal * 0.033814).round();

      // Ghi log để debug
      AppLogger.info('Chuyển đổi từ $dailyGoal ml sang $flOz oz');

      return '$flOz oz';
    }
  }
}
