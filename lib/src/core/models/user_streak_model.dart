import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_streak_model.freezed.dart';
part 'user_streak_model.g.dart';

/// Model representing user's streak information
@freezed
class UserStreakModel with _$UserStreakModel {
  const factory UserStreakModel({
    /// Current streak (consecutive days)
    required int currentStreak,
    
    /// Longest streak ever achieved
    required int longestStreak,
    
    /// Last date when user drank water
    required DateTime lastActiveDate,
  }) = _UserStreakModel;

  const UserStreakModel._();

  /// Factory constructor for creating a UserStreakModel from JSON
  factory UserStreakModel.fromJson(Map<String, dynamic> json) => _$UserStreakModelFromJson(json);

  /// Create a new instance with default values
  factory UserStreakModel.initial() => UserStreakModel(
    currentStreak: 0,
    longestStreak: 0,
    lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
  );
}
