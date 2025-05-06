/// Enum representing different reminder modes for water intake reminders
enum ReminderMode {
  /// Standard mode - reminders are sent at fixed times throughout the day
  standard,
  
  /// Interval mode - reminders are sent at regular intervals
  interval,
  
  /// Custom mode - user can set specific times for reminders
  custom,
}

/// Extension methods for ReminderMode
extension ReminderModeExtension on ReminderMode {
  /// Get a human-readable name for the reminder mode
  String get name {
    switch (this) {
      case ReminderMode.standard:
        return 'Standard';
      case ReminderMode.interval:
        return 'Interval';
      case ReminderMode.custom:
        return 'Custom';
    }
  }
  
  /// Get a description for the reminder mode
  String get description {
    switch (this) {
      case ReminderMode.standard:
        return 'Reminders at optimal times based on your wake-up and bedtime';
      case ReminderMode.interval:
        return 'Reminders at regular intervals throughout your day';
      case ReminderMode.custom:
        return 'Set your own specific reminder times';
    }
  }
}
