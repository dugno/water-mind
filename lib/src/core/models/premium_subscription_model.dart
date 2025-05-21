import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_subscription_model.freezed.dart';
part 'premium_subscription_model.g.dart';

/// Model for premium subscription status
@freezed
class PremiumSubscriptionModel with _$PremiumSubscriptionModel {
  /// Default constructor
  const factory PremiumSubscriptionModel({
    /// Whether the user has an active premium subscription
    @Default(false) bool isActive,

    /// The date when the subscription was purchased
    DateTime? purchaseDate,

    /// The date when the subscription expires (null for lifetime)
    DateTime? expiryDate,

    /// The subscription plan type (e.g., lifetime)
    String? planType,

    /// Whether this is a lifetime purchase (no expiration)
    @Default(false) bool isLifetime,
  }) = _PremiumSubscriptionModel;

  /// Factory constructor for creating a PremiumSubscriptionModel from JSON
  factory PremiumSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$PremiumSubscriptionModelFromJson(json);

  /// Private constructor for the freezed class
  const PremiumSubscriptionModel._();

  /// Create a default model with sensible defaults
  factory PremiumSubscriptionModel.defaultSettings() => const PremiumSubscriptionModel(
    isActive: false,
    isLifetime: false,
  );

  /// Create a lifetime premium model
  factory PremiumSubscriptionModel.lifetime() => PremiumSubscriptionModel(
    isActive: true,
    isLifetime: true,
    purchaseDate: DateTime.now(),
    planType: 'lifetime',
  );
}
