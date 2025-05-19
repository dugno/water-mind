/// Represents a notification channel in the application.
///
/// Notification channels are used to categorize notifications and
/// allow users to control notification behavior at a channel level.
class NotificationChannelModel {
  /// Unique identifier for the channel
  final String channelKey;

  /// Human-readable name for the channel
  final String channelName;

  /// Description of the channel's purpose
  final String channelDescription;

  /// Importance level of notifications in this channel (0-5)
  /// Higher values represent more intrusive notifications
  final int importance;

  /// Whether notifications in this channel can show badges
  final bool showBadge;

  /// Whether notifications in this channel can play sound
  final bool playSound;

  /// Whether notifications in this channel can vibrate the device
  final bool enableVibration;

  /// Whether notifications in this channel can show lights
  final bool enableLights;

  /// Creates a new [NotificationChannelModel] instance.
  const NotificationChannelModel({
    required this.channelKey,
    required this.channelName,
    required this.channelDescription,
    this.importance = 3, // Default to high importance
    this.showBadge = false,
    this.playSound = true,
    this.enableVibration = true,
    this.enableLights = true,
  });

  /// Creates a copy of this channel with the given fields replaced with new values.
  NotificationChannelModel copyWith({
    String? channelKey,
    String? channelName,
    String? channelDescription,
    int? importance,
    bool? showBadge,
    bool? playSound,
    bool? enableVibration,
    bool? enableLights,
  }) {
    return NotificationChannelModel(
      channelKey: channelKey ?? this.channelKey,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      importance: importance ?? this.importance,
      showBadge: showBadge ?? this.showBadge,
      playSound: playSound ?? this.playSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableLights: enableLights ?? this.enableLights,
    );
  }

  /// Converts this channel model to a map.
  Map<String, dynamic> toMap() {
    return {
      'channelKey': channelKey,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'importance': importance,
      'showBadge': showBadge,
      'playSound': playSound,
      'enableVibration': enableVibration,
      'enableLights': enableLights,
    };
  }

  /// Creates a channel model from a map.
  factory NotificationChannelModel.fromMap(Map<String, dynamic> map) {
    return NotificationChannelModel(
      channelKey: map['channelKey'] as String,
      channelName: map['channelName'] as String,
      channelDescription: map['channelDescription'] as String,
      importance: map['importance'] as int? ?? 3,
      showBadge: map['showBadge'] as bool? ?? false,
      playSound: map['playSound'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      enableLights: map['enableLights'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'NotificationChannelModel(channelKey: $channelKey, channelName: $channelName, channelDescription: $channelDescription, importance: $importance, showBadge: $showBadge, playSound: $playSound, enableVibration: $enableVibration, enableLights: $enableLights)';
  }
}
