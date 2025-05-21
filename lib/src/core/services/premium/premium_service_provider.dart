import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/premium_subscription_model.dart';
import 'package:water_mind/src/core/services/premium/premium_service.dart';

/// Provider for premium service
final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumServiceImpl();
});

/// Provider for premium subscription status
final premiumSubscriptionProvider = FutureProvider<PremiumSubscriptionModel>((ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.getSubscriptionStatus();
});

/// Provider to check if premium is active
final isPremiumActiveProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.isPremiumActive();
});

/// Provider for premium status change notifier
/// This provider should be watched by widgets that need to update when premium status changes
final premiumStatusChangeNotifierProvider = StateProvider<int>((ref) => 0);

/// Utility function to notify premium status change
void notifyPremiumStatusChange(WidgetRef ref) {
  final notifier = ref.read(premiumStatusChangeNotifierProvider.notifier);
  notifier.state = notifier.state + 1;
}
