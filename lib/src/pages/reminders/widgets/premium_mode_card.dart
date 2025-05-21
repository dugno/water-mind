import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/haptic/haptic_mixin.dart';
import 'package:water_mind/src/core/services/haptic/haptic_service.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/services/reminders/models/reminder_mode.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_icon.dart';

/// A card for selecting reminder mode with premium check
class PremiumModeCard extends ConsumerStatefulWidget {
  /// The reminder mode this card represents
  final ReminderMode mode;

  /// The icon to display
  final IconData icon;

  /// Whether this mode is currently selected
  final bool isSelected;

  /// Callback when the mode is selected
  final Function(ReminderMode) onSelected;

  /// Constructor
  const PremiumModeCard({
    super.key,
    required this.mode,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  ConsumerState<PremiumModeCard> createState() => _PremiumModeCardState();
}

class _PremiumModeCardState extends ConsumerState<PremiumModeCard> with HapticFeedbackMixin {
  @override
  Widget build(BuildContext context) {
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);
    final requiresPremium = widget.mode != ReminderMode.standard;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () {
          haptic(HapticFeedbackType.selection);

          // Check if premium is required and active
          if (requiresPremium) {
            final isPremiumActive = ref.read(isPremiumActiveProvider).value ?? false;
            if (isPremiumActive) {
              widget.onSelected(widget.mode);
            } else {
              // Show premium subscription page
              _showPremiumDialog(context);
            }
          } else {
            // Standard mode doesn't require premium
            widget.onSelected(widget.mode);
          }
        },
        child: Card(
          elevation: widget.isSelected ? 4 : 1,
          color: widget.isSelected
              ? AppColor.thirdColor
              : AppColor.thirdColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: widget.isSelected
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with premium badge if needed
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                    if (requiresPremium)
                      isPremiumActiveAsync.when(
                        data: (isPremiumActive) {
                          if (!isPremiumActive) {
                            return const Positioned(
                              right: -4,
                              top: -4,
                              child: PremiumIcon(
                                size: 16,
                                color: Colors.white,
                                backgroundColor: AppColor.primaryColor,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.mode.getName(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const PremiumIcon(
              size: 24,
              color: AppColor.primaryColor,
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 8),
            Text(context.l10n.premiumFeature),
          ],
        ),
        content: Text(context.l10n.customReminderModeDesc),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to premium subscription page
              context.router.push(const PremiumSubscriptionRoute());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.subscribeToPremium),
          ),
        ],
      ),
    );
  }
}
