import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'notification_manager.dart';
import 'notification_service_provider.dart';

/// A widget that handles notification actions.
///
/// This widget listens for notification actions (taps) and handles them
/// appropriately. It should be placed high in the widget tree, typically
/// wrapping the MaterialApp.
class NotificationHandler extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new [NotificationHandler] instance.
  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  late final NotificationManager _notificationManager;
  late final StreamSubscription<ReceivedAction> _actionSubscription;

  @override
  void initState() {
    super.initState();
    _notificationManager = NotificationServiceProvider().getNotificationManager();

    // Listen for notification actions (taps)
    _actionSubscription = _notificationManager.onActionStream.listen(_handleNotificationAction);
  }

  void _handleNotificationAction(ReceivedAction action) {
    // Handle the notification action
    debugPrint('Notification tapped: ${action.id}');
    debugPrint('Payload: ${action.payload}');

    // Navigate or perform actions based on the notification
    if (action.payload?['type'] == 'alert') {
      _showAlertDialog(action);
    } else if (action.payload?['type'] == 'reminder') {
      _showReminderDialog(action);
    } else if (action.payload?['counter'] != null) {
      _showCounterDialog(action);
    }
  }

  void _showAlertDialog(ReceivedAction action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Notification Tapped'),
        content: Text('You tapped on an alert notification.\n\nPayload: ${action.payload}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(ReceivedAction action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Notification Tapped'),
        content: Text('You tapped on a reminder notification.\n\nPayload: ${action.payload}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCounterDialog(ReceivedAction action) {
    final counter = action.payload?['counter'] ?? 'unknown';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter Notification Tapped'),
        content: Text('You tapped on a counter notification.\n\nCounter value: $counter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
