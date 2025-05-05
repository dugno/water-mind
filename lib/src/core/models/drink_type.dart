import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drink_type.freezed.dart';
part 'drink_type.g.dart';

/// Converter for IconData
class IconDataConverter implements JsonConverter<IconData, int> {
  const IconDataConverter();

  @override
  IconData fromJson(int json) => IconData(json, fontFamily: 'MaterialIcons');

  @override
  int toJson(IconData object) => object.codePoint;
}

/// Converter for Color
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

/// Model representing different types of drinks
@freezed
class DrinkType with _$DrinkType {
  const factory DrinkType({
    required String id,
    required String name,
    @IconDataConverter() required IconData icon,
    @ColorConverter() required Color color,
    /// Hydration factor (water = 1.0, coffee might be 0.8, etc.)
    @Default(1.0) double hydrationFactor,
  }) = _DrinkType;

  /// Factory constructor for creating a DrinkType from JSON
  factory DrinkType.fromJson(Map<String, dynamic> json) => _$DrinkTypeFromJson(json);
}

/// Predefined drink types
class DrinkTypes {
  // Private constructor to prevent instantiation
  DrinkTypes._();

  /// Water
  static const DrinkType water = DrinkType(
    id: 'water',
    name: 'Water',
    icon: Icons.water_drop,
    color: Colors.blue,
    hydrationFactor: 1.0,
  );

  /// Coffee
  static const DrinkType coffee = DrinkType(
    id: 'coffee',
    name: 'Coffee',
    icon: Icons.coffee,
    color: Colors.brown,
    hydrationFactor: 0.8,
  );

  /// Tea
  static const DrinkType tea = DrinkType(
    id: 'tea',
    name: 'Tea',
    icon: Icons.emoji_food_beverage,
    color: Colors.green,
    hydrationFactor: 0.9,
  );

  /// Juice
  static const DrinkType juice = DrinkType(
    id: 'juice',
    name: 'Juice',
    icon: Icons.local_drink,
    color: Colors.orange,
    hydrationFactor: 0.85,
  );

  /// Milk
  static const DrinkType milk = DrinkType(
    id: 'milk',
    name: 'Milk',
    icon: Icons.opacity,
    color: Colors.grey,
    hydrationFactor: 0.9,
  );

  /// Soda
  static const DrinkType soda = DrinkType(
    id: 'soda',
    name: 'Soda',
    icon: Icons.bubble_chart,
    color: Colors.red,
    hydrationFactor: 0.7,
  );

  /// List of all predefined drink types
  static List<DrinkType> get all => [
    water,
    coffee,
    tea,
    juice,
    milk,
    soda,
  ];
}
