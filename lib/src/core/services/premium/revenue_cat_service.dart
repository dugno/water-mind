import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:water_mind/src/core/models/premium_subscription_model.dart';
import 'package:water_mind/src/core/services/logger/app_logger.dart';

/// RevenueCat API keys
class RevenueCatConfig {
  /// API key for Android
  static const String androidApiKey = 'YOUR_ANDROID_API_KEY';

  /// API key for iOS
  static const String iosApiKey = 'appl_KUsKqDdidLYzMkgEgJDGDpuLSAv';

  /// Premium entitlement identifier
  static const String entitlementId = 'premium';

  /// Lifetime premium product ID
  static const String lifetimeProductId = 'premium_lifetime';

  /// Note: Replace the API keys with your actual RevenueCat API keys
  /// You can get these from your RevenueCat dashboard at https://app.revenuecat.com/
}

/// Service for handling in-app purchases with RevenueCat
class RevenueCatService {
  /// Singleton instance
  static final RevenueCatService _instance = RevenueCatService._internal();

  /// Factory constructor
  factory RevenueCatService() => _instance;

  /// Private constructor
  RevenueCatService._internal();

  /// Stream controller for premium status changes
  final _premiumStatusController = StreamController<bool>.broadcast();

  /// Stream of premium status changes
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  /// Initialize RevenueCat
  Future<void> initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(PurchasesConfiguration(RevenueCatConfig.androidApiKey));
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(PurchasesConfiguration(RevenueCatConfig.iosApiKey));
      }

      // Set up customer info listener
      Purchases.addCustomerInfoUpdateListener((info) {
        _checkPremiumStatus(info);
      });

      // Check initial status
      final customerInfo = await Purchases.getCustomerInfo();
      _checkPremiumStatus(customerInfo);

      AppLogger.info('RevenueCat initialized successfully');
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error initializing RevenueCat');
    }
  }

  /// Check if user has premium entitlement
  void _checkPremiumStatus(CustomerInfo customerInfo) {
    final isPremium = customerInfo.entitlements.active.containsKey(RevenueCatConfig.entitlementId);
    _premiumStatusController.add(isPremium);
  }

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting customer info');
      rethrow;
    }
  }

  /// Check if user has premium entitlement
  Future<bool> isPremiumActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(RevenueCatConfig.entitlementId);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error checking premium status');
      return false;
    }
  }

  /// Get premium subscription model
  Future<PremiumSubscriptionModel> getPremiumSubscriptionModel() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.active[RevenueCatConfig.entitlementId];

      if (entitlement != null) {
        final isLifetime = entitlement.productIdentifier == RevenueCatConfig.lifetimeProductId;

        return PremiumSubscriptionModel(
          isActive: true,
          isLifetime: isLifetime,
          purchaseDate: entitlement.latestPurchaseDate != null
              ? DateTime.parse(entitlement.latestPurchaseDate!)
              : DateTime.now(),
          // For lifetime, expiryDate is null
          expiryDate: isLifetime
              ? null
              : (entitlement.expirationDate != null
                  ? DateTime.parse(entitlement.expirationDate!)
                  : null),
          planType: entitlement.productIdentifier,
        );
      }

      return PremiumSubscriptionModel.defaultSettings();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting premium subscription model');
      return PremiumSubscriptionModel.defaultSettings();
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error getting offerings');
      return null;
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active.containsKey(RevenueCatConfig.entitlementId);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error purchasing package');
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.containsKey(RevenueCatConfig.entitlementId);
    } catch (e) {
      AppLogger.reportError(e, StackTrace.current, 'Error restoring purchases');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _premiumStatusController.close();
  }
}
