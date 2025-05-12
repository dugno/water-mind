import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/database/daos/user_preferences_dao.dart';
import 'package:water_mind/src/core/database/providers/database_providers.dart';
import 'package:water_mind/src/core/models/drink_type.dart';
import 'package:water_mind/src/core/models/user_preferences_model.dart';
import 'package:water_mind/src/core/services/user_preferences/user_preferences_repository.dart';

/// Provider cho UserPreferencesDao
final userPreferencesDaoProvider = Provider<UserPreferencesDao>((ref) {
  final database = ref.watch(databaseProvider);
  return UserPreferencesDao(database);
});

/// Provider cho UserPreferencesRepository
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>((ref) {
  final dao = ref.watch(userPreferencesDaoProvider);
  return UserPreferencesRepositoryImpl(dao);
});

/// Provider cho tùy chọn người dùng
final userPreferencesProvider = FutureProvider<UserPreferencesModel?>((ref) async {
  final repository = ref.watch(userPreferencesRepositoryProvider);
  return repository.getUserPreferences();
});

/// Provider cho loại đồ uống gần nhất
final lastDrinkTypeProvider = Provider.family<DrinkType, UserPreferencesModel?>((ref, preferences) {
  if (preferences?.lastDrinkTypeId == null) {
    return DrinkTypes.water; // Mặc định là nước lọc
  }
  
  // Tìm loại nước dựa trên ID
  final drinkType = DrinkTypes.all.firstWhere(
    (drink) => drink.id == preferences!.lastDrinkTypeId,
    orElse: () => DrinkTypes.water,
  );
  
  return drinkType;
});

/// Provider cho lượng nước uống gần nhất
final lastDrinkAmountProvider = Provider.family<double, UserPreferencesModel?>((ref, preferences) {
  if (preferences?.lastDrinkAmount == null) {
    return 200.0; // Mặc định là 200ml
  }
  
  return preferences!.lastDrinkAmount!;
});
