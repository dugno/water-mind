import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/user/user_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/getting_started/models/getting_started_step.dart';
import 'package:water_mind/src/pages/getting_started/models/user_onboarding_model.dart';
import 'package:water_mind/src/pages/getting_started/segments/activity_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/born_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/end_a_day_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/gender_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/height_weight_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/living_environment_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/wake_up_segment.dart';
import 'package:water_mind/src/pages/getting_started/summary_page.dart';
import 'package:water_mind/src/pages/getting_started/viewmodels/getting_started_viewmodel.dart';
import 'package:water_mind/src/pages/getting_started/widgets/language_selector_fullscreen.dart';
import 'package:water_mind/src/ui/widgets/progress_bar/progress_bar_theme.dart';
import 'package:water_mind/src/ui/widgets/progress_bar/segmented_progress_bar.dart';
import 'package:water_mind/src/core/services/language/language_manager.dart';
import 'package:water_mind/src/core/providers/locale_provider.dart';

/// Screen for the getting started flow
@RoutePage()
class GettingStartedPage extends ConsumerWidget {
  /// Constructor
  const GettingStartedPage({
    super.key,
    this.initialStep = GettingStartedStep.gender,
    this.fromHome = false,
  });

  /// Initial step in the flow
  final GettingStartedStep initialStep;

  /// Whether this screen was opened from home
  final bool fromHome;

  // Language selection
  bool get isEnglish => KVStoreService.appLanguage == 'en';

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _nextStep(WidgetRef ref) {
    _triggerHapticFeedback();

    final viewModel = ref.read(
        gettingStartedViewModelProvider(initialStep: initialStep).notifier);
    final state =
        ref.read(gettingStartedViewModelProvider(initialStep: initialStep));

    if (!state.isLastStep()) {
      viewModel.nextStep();
    } else {
      _completeOnboarding(ref);
    }
  }

  void _previousStep(BuildContext context, WidgetRef ref) {
    _triggerHapticFeedback();

    final viewModel = ref.read(
        gettingStartedViewModelProvider(initialStep: initialStep).notifier);
    final state =
        ref.read(gettingStartedViewModelProvider(initialStep: initialStep));

    if (state.currentStep.index > 0) {
      viewModel.previousStep();
    } else if (!fromHome) {
      Navigator.of(context).pop();
    }
  }

  void _completeOnboarding(WidgetRef ref) {
    // Get the current user model from the view model
    final userModel = ref.read(gettingStartedViewModelProvider(initialStep: initialStep));
    final context = ref.context;

    // Save user data to storage using UserNotifier
    final userNotifier = ref.read(userNotifierProvider.notifier);

    // Use a separate async function to avoid BuildContext across async gaps
    _saveUserDataAndNavigate(userNotifier, userModel, context);
  }

  // Helper method to save data and navigate
  Future<void> _saveUserDataAndNavigate(
    UserNotifier userNotifier,
    UserOnboardingModel userModel,
    BuildContext context
  ) async {
    // Save user data
    await userNotifier.saveUserData(userModel);

    // Do NOT mark getting started as completed yet
    // This will be done in the summary page when the user clicks "Get Started"

    // Check if context is still valid before navigating
    if (context.mounted) {
      // Navigate to the summary page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SummaryPage(userModel: userModel),
        ),
      );
    }
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    // Lấy ngôn ngữ hiện tại từ KVStoreService
    final currentLanguage = KVStoreService.appLanguage;

    // Hiển thị màn hình chọn ngôn ngữ toàn màn hình
    LanguageSelectorFullscreen.show(
      context: context,
      currentLanguage: currentLanguage,
      onLanguageSelected: (languageCode) async {
        // Cập nhật ngôn ngữ trong locale provider (sẽ tự động cập nhật KVStoreService)
        await ref.read(localeProvider.notifier).setLocale(languageCode);
        AppLogger.info('Language changed to: $languageCode');

        // Force rebuild to update the language selector UI
        if (context.mounted) {
          // Invalidate the state to trigger a rebuild
          ref.invalidate(gettingStartedViewModelProvider(initialStep: initialStep));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(gettingStartedViewModelProvider(initialStep: initialStep));

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.secondaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildStatusBar(context, ref),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    state.currentStep.getTitle(context),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.currentStep.getDescription(context),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                child: _buildCurrentStep(context, ref),
              ),
            ),

            // Next button for wheel picker segments
            if (state.needsNextButton())
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: state.isCurrentStepValid()
                        ? () => _nextStep(ref)
                        : null,
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
                      state.isLastStep()
                          ? context.l10n.getStarted
                          : context.l10n.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(
        gettingStartedViewModelProvider(initialStep: initialStep).notifier);
    final state =
        ref.read(gettingStartedViewModelProvider(initialStep: initialStep));

    switch (state.currentStep) {
      case GettingStartedStep.gender:
        return GenderSegment(
          initialGender: state.gender,
          onGenderSelected: (gender) {
            viewModel.updateGender(gender);
            Future.delayed(
                const Duration(milliseconds: 300), () => _nextStep(ref));
          },
        );
      case GettingStartedStep.heightWeight:
        return HeightWeightSegment(
          initialHeight: state.height,
          initialWeight: state.weight,
          initialUnit: state.measureUnit,
          onHeightWeightSelected: (height, weight, unit) {
            viewModel.updateHeightWeight(height, weight, unit);
            // No auto-navigation for this segment as it requires manual input
          },
        );
      case GettingStartedStep.dateOfBirth:
        return BornSegment(
          initialDate: state.dateOfBirth,
          onDateSelected: (date) {
            viewModel.updateDateOfBirth(date);
            // No auto-navigation for wheel picker segments
          },
        );
      case GettingStartedStep.activityLevel:
        return ActivitySegment(
          initialActivity: state.activityLevel,
          onActivitySelected: (activity) {
            viewModel.updateActivityLevel(activity);
            // Auto-navigate to next step after selection
            Future.delayed(
                const Duration(milliseconds: 300), () => _nextStep(ref));
          },
        );
      case GettingStartedStep.livingEnvironment:
        return LivingEnvironmentSegment(
          initialEnvironment: state.livingEnvironment,
          onEnvironmentSelected: (environment) {
            viewModel.updateLivingEnvironment(environment);
            // Auto-navigate to next step after selection
            Future.delayed(
                const Duration(milliseconds: 300), () => _nextStep(ref));
          },
        );
      case GettingStartedStep.wakeUpTime:
        return WakeUpSegment(
          initialTime: state.wakeUpTime,
          onTimeSelected: (time) {
            viewModel.updateWakeUpTime(time);
            // No auto-navigation for wheel picker segments
          },
        );
      case GettingStartedStep.bedTime:
        return EndADaySegment(
          initialTime: state.bedTime,
          onTimeSelected: (time) {
            viewModel.updateBedTime(time);
            // No auto-navigation for wheel picker segments
          },
        );
      }
  }

  /// Build the status bar with back button and progress bar
  Widget _buildStatusBar(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(gettingStartedViewModelProvider(initialStep: initialStep));
    final bool showBackButton = state.currentStep.index > 0 || fromHome;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (showBackButton)...[
            GestureDetector(
              onTap: () => _previousStep(context, ref),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          const SizedBox(width: 16),
          ] else ...[
            const SizedBox(width: 44),
          ],


          Expanded(
            child: SegmentedProgressBar(
              completedSteps: state.currentStep.index,
              totalSteps: GettingStartedStep.totalSteps,
              showLabel: false,
              theme: ProgressBarTheme(
                completedSegmentColor: AppColor.thirdColor,
                incompleteSegmentColor: Colors.white24,
                labelColor: Colors.white,
                segmentWidth: 12,
                segmentHeight: 4,
                segmentSpacing: 4,
                segmentBorderRadius: BorderRadius.circular(2),
                showPulsingEffect: false,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Language selector
          GestureDetector(
            onTap: () => _showLanguageSelector(context, ref),
            child: FutureBuilder<LanguageModel?>(
              future: LanguageManager.getLanguageByCode(KVStoreService.appLanguage),
              builder: (context, snapshot) {
                // Default values if data is not loaded yet
                String flagPath = isEnglish
                    ? 'assets/images/language/united_kingdom.png'
                    : 'assets/images/language/vietnam.png';
                String abbreviation = isEnglish ? 'EN' : 'VI';

                // Use data from LanguageManager if available
                if (snapshot.hasData && snapshot.data != null) {
                  flagPath = snapshot.data!.imagePath;
                  abbreviation = snapshot.data!.abbreviation;
                }

                return Row(
                  children: [
                    Image.asset(
                      flagPath,
                      width: 16,
                      height: 12,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.language, size: 16, color: Colors.white);
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      abbreviation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
