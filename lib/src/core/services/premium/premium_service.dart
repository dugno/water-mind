import 'dart:convert';

import 'package:water_mind/src/core/models/premium_subscription_model.dart';
import 'package:water_mind/src/core/services/kv_store/kv_store.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';
import 'package:water_mind/src/core/services/premium/revenue_cat_service.dart';

/// Interface for premium subscription service
abstract class PremiumService {
  /// Get the current premium subscription status
  Future<PremiumSubscriptionModel> getSubscriptionStatus();

  /// Update the premium subscription status
  Future<void> updateSubscriptionStatus(PremiumSubscriptionModel status);

  /// Check if the user has an active premium subscription
  Future<bool> isPremiumActive();

  /// Check if the user has an active premium subscription (synchronous version)
  /// This is used for cases where an async call is not possible
  bool isPremiumActiveSync();

  /// Activate premium subscription (for testing or after purchase)
  Future<void> activatePremium({String? planType, DateTime? expiryDate});

  /// Deactivate premium subscription
  Future<void> deactivatePremium();

  /// Restore purchases from the store
  Future<bool> restorePurchases();
}

/// Implementation of premium subscription service
class PremiumServiceImpl implements PremiumService {
  static const String _premiumStatusKey = 'premium_subscription_status';
  final RevenueCatService _revenueCatService = RevenueCatService();

  @override
  Future<PremiumSubscriptionModel> getSubscriptionStatus() async {
    try {
      // First try to get status from RevenueCat
      try {
        final revenueCatStatus = await _revenueCatService.getPremiumSubscriptionModel();
        // If we got a valid status from RevenueCat, update local cache and return it
        if (revenueCatStatus.isActive) {
          await updateSubscriptionStatus(revenueCatStatus);
          return revenueCatStatus;
        }
      } catch (e) {
        AppLogger.reportError(e, StackTrace.current, 'Error getting status from RevenueCat, falling back to local cache');
      }

      // Fall back to local cache if RevenueCat fails
      final jsonString = KVStoreService.sharedPreferences.getString(_premiumStatusKey);
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);
        return PremiumSubscriptionModel.fromJson(jsonData);
      }
      return PremiumSubscriptionModel.defaultSettings();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting premium subscription status');
      return PremiumSubscriptionModel.defaultSettings();
    }
  }

  @override
  Future<void> updateSubscriptionStatus(PremiumSubscriptionModel status) async {
    try {
      final jsonString = jsonEncode(status.toJson());
      await KVStoreService.sharedPreferences.setString(_premiumStatusKey, jsonString);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error updating premium subscription status');
      rethrow;
    }
  }

  @override
  Future<bool> isPremiumActive() async {
    try {
      // First try to check with RevenueCat
      final isActiveFromRevenueCat = await _revenueCatService.isPremiumActive();
      if (isActiveFromRevenueCat) {
        return true;
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error checking premium status with RevenueCat, falling back to local cache');
    }

    // Fall back to local cache if RevenueCat fails
    final status = await getSubscriptionStatus();

    // If it's a lifetime purchase, it's always active
    if (status.isActive && status.isLifetime) {
      return true;
    }

    // Check if subscription is active and not expired
    if (status.isActive && status.expiryDate != null) {
      final now = DateTime.now();
      return now.isBefore(status.expiryDate!);
    }

    return status.isActive;
  }

  @override
  bool isPremiumActiveSync() {
    try {
      // Get the cached status from KVStore synchronously
      final jsonData = KVStoreService.sharedPreferences.getString(_premiumStatusKey);
      if (jsonData != null) {
        final Map<String, dynamic> data = jsonDecode(jsonData);
        final status = PremiumSubscriptionModel.fromJson(data);

        // If it's a lifetime purchase, it's always active
        if (status.isActive && status.isLifetime) {
          return true;
        }

        // Check if subscription is active and not expired
        if (status.isActive && status.expiryDate != null) {
          final now = DateTime.now();
          return now.isBefore(status.expiryDate!);
        }

        return status.isActive;
      }
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error checking premium status synchronously');
    }

    // Default to false if there's an error or no data
    return false;
  }

  @override
  Future<void> activatePremium({String? planType, DateTime? expiryDate}) async {
    final now = DateTime.now();

    // Check if this is a lifetime activation
    final isLifetime = planType == 'lifetime' || planType == RevenueCatConfig.lifetimeProductId;

    // For lifetime, no expiry date is needed
    final PremiumSubscriptionModel newStatus;

    if (isLifetime) {
      newStatus = PremiumSubscriptionModel.lifetime();
    } else {
      final expiry = expiryDate ?? now.add(const Duration(days: 30)); // Default to 30 days
      newStatus = PremiumSubscriptionModel(
        isActive: true,
        purchaseDate: now,
        expiryDate: expiry,
        planType: planType ?? 'lifetime', // Default to lifetime
        isLifetime: isLifetime,
      );
    }

    await updateSubscriptionStatus(newStatus);
  }

  @override
  Future<void> deactivatePremium() async {
    const newStatus = PremiumSubscriptionModel(
      isActive: false,
      purchaseDate: null,
      expiryDate: null,
      planType: null,
    );

    await updateSubscriptionStatus(newStatus);
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      return await _revenueCatService.restorePurchases();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error restoring purchases');
      return false;
    }
  }
}
