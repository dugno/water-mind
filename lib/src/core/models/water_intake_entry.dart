import 'package:freezed_annotation/freezed_annotation.dart';
import 'drink_type.dart';

part 'water_intake_entry.freezed.dart';
part 'water_intake_entry.g.dart';

/// Model representing a single water intake entry
@freezed
class WaterIntakeEntry with _$WaterIntakeEntry {
  const factory WaterIntakeEntry({
    required String id,
    required DateTime timestamp,
    required double amount, // in milliliters or fluid ounces
    required DrinkType drinkType,
    String? note,
  }) = _WaterIntakeEntry;

  const WaterIntakeEntry._();

  /// Factory constructor for creating a WaterIntakeEntry from JSON
  factory WaterIntakeEntry.fromJson(Map<String, dynamic> json) => _$WaterIntakeEntryFromJson(json);

  /// Get the effective hydration amount (amount * hydration factor)
  double get effectiveAmount => amount * drinkType.hydrationFactor;
}


