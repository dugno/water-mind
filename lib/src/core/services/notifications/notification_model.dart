/// Represents a notification in the application.
///
/// This model follows the Single Responsibility Principle by only handling
/// notification data representation.
class AppNotificationModel {
  /// Unique identifier for the notification
  final int id;

  /// The notification channel ID
  final String channelKey;

  /// The title of the notification
  final String title;

  /// The body content of the notification
  final String body;

  /// Optional payload data associated with the notification
  final Map<String, String>? payload;

  /// Optional notification category/group
  final String? category;

  /// Optional notification importance level
  final int? importance;

  /// Creates a new [AppNotificationModel] instance.
  const AppNotificationModel({
    required this.id,
    required this.channelKey,
    required this.title,
    required this.body,
    this.payload,
    this.category,
    this.importance,
  });

  /// Creates a copy of this notification with the given fields replaced with new values.
  AppNotificationModel copyWith({
    int? id,
    String? channelKey,
    String? title,
    String? body,
    Map<String, String>? payload,
    String? category,
    int? importance,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      channelKey: channelKey ?? this.channelKey,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      category: category ?? this.category,
      importance: importance ?? this.importance,
    );
  }

  /// Converts this notification model to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channelKey': channelKey,
      'title': title,
      'body': body,
      'payload': payload,
      'category': category,
      'importance': importance,
    };
  }

  /// Creates a notification model from a map.
  factory AppNotificationModel.fromMap(Map<String, dynamic> map) {
    return AppNotificationModel(
      id: map['id'] as int,
      channelKey: map['channelKey'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      payload: map['payload'] != null
          ? Map<String, String>.from(map['payload'] as Map)
          : null,
      category: map['category'] as String?,
      importance: map['importance'] as int?,
    );
  }

  @override
  String toString() {
    return 'AppNotificationModel(id: $id, channelKey: $channelKey, title: $title, body: $body, payload: $payload, category: $category, importance: $importance)';
  }
}
