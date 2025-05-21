import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/premium/premium_service_provider.dart';
import 'package:water_mind/src/core/services/premium/revenue_cat_service.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/ui/widgets/premium/premium_icon.dart';

/// Premium subscription page
@RoutePage()
class PremiumSubscriptionPage extends ConsumerStatefulWidget {
  /// Constructor
  const PremiumSubscriptionPage({super.key});

  @override
  ConsumerState<PremiumSubscriptionPage> createState() => _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState extends ConsumerState<PremiumSubscriptionPage> {
  final RevenueCatService _revenueCatService = RevenueCatService();
  Offerings? _offerings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final offerings = await _revenueCatService.getOfferings();
      setState(() {
        _offerings = offerings;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error loading offerings');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumActiveAsync = ref.watch(isPremiumActiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.premiumSubscription),
        backgroundColor: AppColor.secondaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: context.l10n.restorePurchases,
            onPressed: () async {
              final service = ref.read(premiumServiceProvider);
              final restored = await service.restorePurchases();
              if (restored) {
                notifyPremiumStatusChange(ref);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.purchasesRestored)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.noPurchasesToRestore)),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.secondaryColor,
              AppColor.backgroundColor,
            ],
          ),
        ),
        child: isPremiumActiveAsync.when(
          data: (isPremiumActive) {
            return isPremiumActive
                ? _buildActivePremiumContent(context, ref)
                : _buildPremiumOfferContent(context, ref);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              context.l10n.errorLoadingPremiumStatus,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivePremiumContent(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PremiumIcon(
            size: 64,
            color: Colors.white,
            backgroundColor: AppColor.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.premiumActive,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.enjoyPremiumFeatures,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // For testing purposes, add a button to deactivate premium
          ElevatedButton(
            onPressed: () async {
              final service = ref.read(premiumServiceProvider);
              await service.deactivatePremium();
              notifyPremiumStatusChange(ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(context.l10n.deactivatePremium),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumOfferContent(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Premium icon and title
          Center(
            child: Column(
              children: [
                const PremiumIcon(
                  size: 64,
                  color: Colors.white,
                  backgroundColor: AppColor.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.premiumSubscription,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.unlockPremiumFeatures,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Premium features list
          _buildFeatureItem(
            context,
            Icons.water_drop,
            context.l10n.weatherBasedWaterIntake,
            context.l10n.weatherBasedWaterIntakeDesc,
          ),
          _buildFeatureItem(
            context,
            Icons.local_drink,
            context.l10n.customDrinkAmount,
            context.l10n.customDrinkAmountDesc,
          ),
          _buildFeatureItem(
            context,
            Icons.emoji_food_beverage,
            context.l10n.customDrinkType,
            context.l10n.customDrinkTypeDesc,
          ),
          _buildFeatureItem(
            context,
            Icons.notifications_active,
            context.l10n.customReminderMode,
            context.l10n.customReminderModeDesc,
          ),
          _buildFeatureItem(
            context,
            Icons.flag,
            context.l10n.customDailyGoal,
            context.l10n.customDailyGoalDesc,
          ),

          const SizedBox(height: 32),

          // Subscription options
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_offerings == null || _offerings!.current == null)
            Center(
              child: Column(
                children: [
                  Text(
                    context.l10n.errorLoadingSubscriptions,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOfferings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColor.primaryColor,
                    ),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Text(
                  context.l10n.unlockPremiumForever,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ..._buildSubscriptionOptions(context, ref),
              ],
            ),

          // For testing purposes
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () async {
              // For testing only
              final service = ref.read(premiumServiceProvider);
              await service.activatePremium(planType: 'lifetime');
              notifyPremiumStatusChange(ref);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text("Activate Lifetime Premium (Testing Only)"),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubscriptionOptions(BuildContext context, WidgetRef ref) {
    final currentOffering = _offerings!.current;
    if (currentOffering == null) return [];

    final packages = currentOffering.availablePackages;
    if (packages.isEmpty) return [];

    // Find the lifetime package
    Package? lifetimePackage;
    for (final package in packages) {
      if (package.identifier == RevenueCatConfig.lifetimeProductId) {
        lifetimePackage = package;
        break;
      }
    }

    // If no lifetime package found, use the first available package
    final packageToShow = lifetimePackage ?? packages.first;

    // Get the price string directly from the package
    final price = packageToShow.storeProduct.priceString;

    return [
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _purchasePackage(packageToShow, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.lifetimePremium,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.lifetimePremiumDesc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    ];
  }

  Future<void> _purchasePackage(Package package, WidgetRef ref) async {
    try {
      final success = await _revenueCatService.purchasePackage(package);
      if (success) {
        notifyPremiumStatusChange(ref);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.purchaseSuccessful)),
          );
        }
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error purchasing package');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.purchaseFailed)),
        );
      }
    }
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
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
