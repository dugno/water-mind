import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

part 'user_preferences_model.freezed.dart';
part 'user_preferences_model.g.dart';

/// Model cho tùy chọn người dùng
@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  /// Constructor
  const factory UserPreferencesModel({
    /// ID của loại nước uống gần nhất
    String? lastDrinkTypeId,
    
    /// Lượng nước uống gần nhất (ml hoặc fl oz)
    double? lastDrinkAmount,
    
    /// Đơn vị đo lường (0: metric, 1: imperial)
    required MeasureUnit measureUnit,
    
    /// Thời gian cập nhật cuối cùng
    DateTime? lastUpdated,
  }) = _UserPreferencesModel;

  /// Factory constructor for creating a UserPreferencesModel from JSON
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) => 
      _$UserPreferencesModelFromJson(json);
      
  /// Private constructor for the freezed class
  const UserPreferencesModel._();
  
  /// Create a default model with sensible defaults
  factory UserPreferencesModel.defaultSettings() => const UserPreferencesModel(
    lastDrinkTypeId: 'water',
    lastDrinkAmount: 200.0,
    measureUnit: MeasureUnit.metric,
  );
}
