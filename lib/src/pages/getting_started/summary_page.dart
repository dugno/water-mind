import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/notifications/notification_riverpod_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/ui/widgets/hydration/water_intake_display.dart';


/// Screen for displaying a summary of the user's information after completing the getting started flow
@RoutePage()
class SummaryPage extends ConsumerWidget {
  /// The user model containing all the information collected during onboarding
  final UserOnboardingModel userModel;

  /// Constructor
  const SummaryPage({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Thay đổi màu nút back thành trắng
        title: Text(
          context.l10n.congratulations,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                context.l10n.profileSetupComplete,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User information summary
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primaryColor.withAlpha(204), // 0.8 opacity
                              AppColor.secondaryColor.withAlpha(179), // 0.7 opacity
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor.withAlpha(77), // 0.3 opacity
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.yourProfile,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              context,
                              Icons.person,
                              context.l10n.gender,
                              _normalizeValue(userModel.gender?.getString(context) ?? '-'),
                            ),
                            _buildProfileItem(
                              context,
                              Icons.height,
                              context.l10n.height,
                              userModel.height != null
                                  ? '${userModel.height} ${userModel.measureUnit == MeasureUnit.metric ? 'cm' : 'ft'}'
                                  : '-',
                            ),
                            _buildProfileItem(
                              context,
                              Icons.monitor_weight,
                              context.l10n.weight,
                              userModel.weight != null
                                  ? '${userModel.weight} ${userModel.measureUnit == MeasureUnit.metric ? 'kg' : 'lb'}'
                                  : '-',
                            ),
                            _buildProfileItem(
                              context,
                              Icons.directions_run,
                              context.l10n.activityLevel,
                              _normalizeValue(userModel.activityLevel?.getString(context) ?? '-'),
                            ),
                            _buildProfileItem(
                              context,
                              Icons.wb_sunny,
                              context.l10n.livingEnvironment,
                              _normalizeValue(userModel.livingEnvironment?.getString(context) ?? '-'),
                            ),
                            _buildProfileItem(
                              context,
                              Icons.access_time,
                              context.l10n.wakeUpTime,
                              userModel.wakeUpTime != null
                                  ? '${userModel.wakeUpTime!.hour}:${userModel.wakeUpTime!.minute.toString().padLeft(2, '0')}'
                                  : '-',
                            ),
                            _buildProfileItem(
                              context,
                              Icons.nightlight,
                              context.l10n.bedTime,
                              userModel.bedTime != null
                                  ? '${userModel.bedTime!.hour}:${userModel.bedTime!.minute.toString().padLeft(2, '0')}'
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Water intake recommendation
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.thirdColor.withAlpha(204), // 0.8 opacity
                              AppColor.fourColor.withAlpha(179), // 0.7 opacity
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.thirdColor.withAlpha(77), // 0.3 opacity
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: WaterIntakeDisplay(
                          userModel: userModel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Continue button
              ElevatedButton(
                onPressed: () => _continueToHome(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.thirdColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  context.l10n.getStarted,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a profile item with an icon and text
  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    // Chuẩn hóa label: viết hoa chữ cái đầu, các chữ còn lại viết thường
    final normalizedLabel = _normalizeLabel(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$normalizedLabel: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chuẩn hóa label: viết hoa chữ cái đầu, các chữ còn lại viết thường
  String _normalizeLabel(String label) {
    if (label.isEmpty) return label;

    // Chuyển tất cả thành chữ thường trước
    final lowercase = label.toLowerCase();

    // Viết hoa chữ cái đầu
    return lowercase[0].toUpperCase() + lowercase.substring(1);
  }

  /// Chuẩn hóa giá trị: viết hoa chữ cái đầu, các chữ còn lại viết thường
  String _normalizeValue(String value) {
    if (value.isEmpty || value == '-') return value;

    // Nếu giá trị chứa nhiều từ cách nhau bởi dấu cách
    if (value.contains(' ')) {
      final words = value.split(' ');
      final normalizedWords = words.map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      });
      return normalizedWords.join(' ');
    }

    // Nếu giá trị chỉ có một từ
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// Continue to the home screen
  void _continueToHome(BuildContext context, WidgetRef ref) async {
    // Mark getting started as completed
    await KVStoreService.setDoneGettingStarted(true);

    // Request notification permission
    final notificationManager = ref.read(notificationManagerProvider);
    final permissionGranted = await notificationManager.requestPermission();
    AppLogger.info('Notification permission request result: $permissionGranted');

    // Navigate to home screen
    if (context.mounted) {
      context.router.replaceAll([const MainNavigationRoute()]);
    }
  }
}
