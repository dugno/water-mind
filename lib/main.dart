import 'package:flutter/material.dart';
import 'src/core/services/notifications/notifications.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  final notificationManager = NotificationServiceProvider().getNotificationManager();
  await notificationManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NotificationHandler(
      child: MaterialApp(
        title: 'Notification Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Awesome Notifications Demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late final NotificationManager _notificationManager;

  @override
  void initState() {
    super.initState();
    // Get the notification manager instance
    _notificationManager = NotificationServiceProvider().getNotificationManager();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Show a notification when counter is incremented
    if (_counter % 5 == 0) {
      _showCounterNotification();
    }
  }

  void _showCounterNotification() {
    final notification = NotificationFactory.createBasicNotification(
      channelKey: 'general_channel',
      title: 'Counter Updated',
      body: 'Your counter has reached $_counter!',
      payload: {'counter': '$_counter'},
    );

    _notificationManager.showNotification(notification);
  }

  void _showAlertNotification() {
    final notification = NotificationFactory.createAlertNotification(
      channelKey: 'alerts_channel',
      title: 'Important Alert!',
      body: 'This is a high-priority notification',
      payload: {'type': 'alert'},
    );

    _notificationManager.showNotification(notification);
  }

  void _scheduleReminder() {
    final notification = NotificationFactory.createReminderNotification(
      channelKey: 'reminders_channel',
      title: 'Reminder',
      body: 'This is a scheduled reminder (10 seconds from now)',
      payload: {'type': 'reminder'},
    );

    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    _notificationManager.scheduleNotification(notification, scheduledTime);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            const Text(
              'Notification Examples:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAlertNotification,
              child: const Text('Show Alert Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _scheduleReminder,
              child: const Text('Schedule Reminder (10s)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _notificationManager.cancelAllNotifications(),
              child: const Text('Cancel All Notifications'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment (shows notification every 5 counts)',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
