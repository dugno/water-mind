import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                context.l10n.congratulations,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF03045E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.profileSetupComplete,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // User information summary
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.yourProfile,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF03045E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileItem(
                        context,
                        Icons.person,
                        context.l10n.gender,
                        userModel.gender?.getString(context).toUpperCase() ?? '-',
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
                        userModel.activityLevel?.getString(context) ?? '-',
                      ),
                      _buildProfileItem(
                        context,
                        Icons.wb_sunny,
                        context.l10n.livingEnvironment,
                        userModel.livingEnvironment?.getString(context) ?? '-',
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
              ),
              const SizedBox(height: 24),

              // Water intake recommendation
              Expanded(
                child: WaterIntakeDisplay(
                  userModel: userModel,
                ),
              ),
              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed: () => _continueToHome(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03045E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF03045E),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Continue to the home screen
  void _continueToHome(BuildContext context, WidgetRef ref) async {
    // Mark getting started as completed
    await KVStoreService.setDoneGettingStarted(true);

    // Navigate to home screen
    if (context.mounted) {
      context.router.replaceAll([const MainNavigationRoute()]);
    }
  }
}
