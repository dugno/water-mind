import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_icon.dart';

/// A widget that displays a premium feature lock overlay
class PremiumFeatureLock extends ConsumerWidget {
  /// The child widget
  final Widget child;
  
  /// The message to display
  final String? message;
  
  /// Constructor
  const PremiumFeatureLock({
    super.key,
    required this.child,
    this.message,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);
    
    return isPremiumActiveAsync.when(
      data: (isPremiumActive) {
        if (isPremiumActive) {
          return child;
        }
        
        return Stack(
          children: [
            Opacity(
              opacity: 0.5,
              child: child,
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.router.push(const PremiumSubscriptionRoute());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PremiumIcon(
                            size: 32,
                            color: Colors.white,
                            backgroundColor: AppColor.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message ?? context.l10n.premiumFeatureMessage,
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
              ),
            ),
          ],
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

/// Extension method to check if premium is active
extension PremiumCheckExtension on WidgetRef {
  /// Check if premium is active
  bool isPremiumActive() {
    final isPremiumActiveAsync = watch(isPremiumActiveProvider);
    return isPremiumActiveAsync.value ?? false;
  }
}
