# Awesome Notifications Service

This is a professional implementation of a notification service using the `awesome_notifications` package, designed following SOLID, DRY, and other best design principles.

## Design Principles Applied

1. **Single Responsibility Principle (SRP)**: Each class has a single responsibility.
   - `NotificationModel` - Represents notification data
   - `NotificationChannelModel` - Represents channel data
   - `NotificationManager` - Manages notification operations
   - `NotificationFactory` - Creates notification objects

2. **Open/Closed Principle (OCP)**: The code is open for extension but closed for modification.
   - New notification types can be added to the factory without modifying existing code
   - New channel types can be added without changing the core implementation

3. **Liskov Substitution Principle (LSP)**: Implementations can be substituted for their interfaces.
   - `AwesomeNotificationService` implements `NotificationServiceInterface`
   - Different notification service implementations can be swapped without changing client code

4. **Interface Segregation Principle (ISP)**: Clients only depend on methods they use.
   - `NotificationServiceInterface` provides a focused set of methods
   - Higher-level abstractions like `NotificationManager` hide complexity

5. **Dependency Inversion Principle (DIP)**: High-level modules depend on abstractions.
   - `NotificationManager` depends on `NotificationServiceInterface`, not concrete implementations
   - `NotificationServiceProvider` provides abstractions to clients

6. **DRY (Don't Repeat Yourself)**: Code reuse is maximized.
   - Common notification creation logic is in the factory
   - Barrel file exports all components for easy importing

7. **Factory Pattern**: Used for creating notification objects.
   - `NotificationFactory` encapsulates notification creation logic

8. **Singleton Pattern**: Used for service providers.
   - `NotificationServiceProvider` ensures only one instance exists

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/services/notifications/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get the notification manager
  final notificationManager = NotificationServiceProvider().getNotificationManager();
  
  // Initialize notifications
  await notificationManager.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationDemo(),
    );
  }
}

class NotificationDemo extends StatelessWidget {
  NotificationDemo({Key? key}) : super(key: key);

  final notificationManager = NotificationServiceProvider().getNotificationManager();

  void _showBasicNotification() {
    final notification = NotificationFactory.createBasicNotification(
      channelKey: 'general_channel',
      title: 'Basic Notification',
      body: 'This is a basic notification',
    );
    
    notificationManager.showNotification(notification);
  }

  void _showAlertNotification() {
    final notification = NotificationFactory.createAlertNotification(
      channelKey: 'alerts_channel',
      title: 'Alert!',
      body: 'This is an important alert',
    );
    
    notificationManager.showNotification(notification);
  }

  void _scheduleReminder() {
    final notification = NotificationFactory.createReminderNotification(
      channelKey: 'reminders_channel',
      title: 'Reminder',
      body: 'This is a scheduled reminder',
    );
    
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    notificationManager.scheduleNotification(notification, scheduledTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showBasicNotification,
              child: const Text('Show Basic Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAlertNotification,
              child: const Text('Show Alert Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scheduleReminder,
              child: const Text('Schedule Reminder (10s)'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Listening for Notification Actions

```dart
class NotificationHandler extends StatefulWidget {
  final Widget child;
  
  const NotificationHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  late final NotificationManager _notificationManager;
  late final StreamSubscription _actionSubscription;
  
  @override
  void initState() {
    super.initState();
    _notificationManager = NotificationServiceProvider().getNotificationManager();
    
    // Listen for notification actions (taps)
    _actionSubscription = _notificationManager.onActionStream.listen(_handleNotificationAction);
  }
  
  void _handleNotificationAction(ReceivedAction action) {
    // Handle the notification action
    print('Notification tapped: ${action.id}');
    print('Payload: ${action.payload}');
    
    // Navigate or perform actions based on the notification
    if (action.payload?['type'] == 'message') {
      // Navigate to message screen
    } else if (action.payload?['type'] == 'reminder') {
      // Navigate to reminder details
    }
  }
  
  @override
  void dispose() {
    _actionSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

## Creating Custom Channels

```dart
// Create a custom high-priority channel
final customChannel = NotificationChannelModel(
  channelKey: 'critical_alerts',
  channelName: 'Critical Alerts',
  channelDescription: 'Very important notifications that cannot be missed',
  importance: 5,
  enableVibration: true,
  playSound: true,
  enableLights: true,
);

// Register the channel
await notificationManager.createChannel(customChannel);

// Use the custom channel
final criticalNotification = NotificationFactory.createAlertNotification(
  channelKey: 'critical_alerts',
  title: 'Critical Alert',
  body: 'This is a critical notification',
);

notificationManager.showNotification(criticalNotification);
```
