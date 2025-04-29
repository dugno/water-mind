import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/app.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: App(),
    ),
  );
}