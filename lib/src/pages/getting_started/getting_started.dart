import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/getting_started/models/getting_started_step.dart';
import 'package:water_mind/src/pages/getting_started/segments/activity_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/born_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/end_a_day_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/gender_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/height_weight_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/living_environment_segment.dart';
import 'package:water_mind/src/pages/getting_started/segments/wake_up_segment.dart';
import 'package:water_mind/src/pages/getting_started/viewmodels/getting_started_viewmodel.dart';
import 'package:water_mind/src/ui/widgets/progress_bar/progress_bar_theme.dart';
import 'package:water_mind/src/ui/widgets/progress_bar/segmented_progress_bar.dart';

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
  bool get isEnglish => true; // Placeholder, replace with actual implementation

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
    // Save user data and navigate to home screen
    final viewModel = ref.read(
        gettingStartedViewModelProvider(initialStep: initialStep).notifier);
    final userData = viewModel.completeOnboarding();

    // TODO: Save userData to storage
    // This is a placeholder, replace with actual implementation

    // Navigate back to the previous screen or home
    Navigator.of(ref.context).pop(userData);
  }

  void _showLanguageSelector() {
    // Show language selector
    // This is a placeholder, replace with actual implementation
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(gettingStartedViewModelProvider(initialStep: initialStep));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status bar with back button and progress bar
            _buildStatusBar(context, ref),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  Text(
                    state.currentStep.getTitle(context),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.currentStep.getDescription(context),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _buildCurrentStep(context, ref),
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
                      backgroundColor: const Color(0xFF03045E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      state.isLastStep()
                          ? context.l10n.getStarted
                          : context.l10n.next,
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
            // Auto-navigate to next step after selection
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
      default:
        return const SizedBox.shrink();
    }
  }

  /// Build the status bar with back button and progress bar
  Widget _buildStatusBar(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(gettingStartedViewModelProvider(initialStep: initialStep));

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => _previousStep(context, ref),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF666666),
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Progress bar
          Expanded(
            child: SegmentedProgressBar(
              completedSteps: state.currentStep.index,
              totalSteps: GettingStartedStep.totalSteps,
              showLabel: false,
              theme: ProgressBarTheme(
                completedSegmentColor: const Color(0xFF03045E),
                incompleteSegmentColor: const Color(0xFFD3D3D3),
                labelColor: Theme.of(context).colorScheme.onSurface,
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
            onTap: _showLanguageSelector,
            child: Row(
              children: [
                Image.asset(
                  isEnglish
                      ? 'assets/images/flags/us.png'
                      : 'assets/images/flags/vn.png',
                  width: 16,
                  height: 12,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.language, size: 16);
                  },
                ),
                const SizedBox(width: 4),
                Text(
                  isEnglish ? 'EN' : 'VI',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
