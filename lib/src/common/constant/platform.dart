import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Platform constants
final bool kIsAndroid = !kIsWeb && Platform.isAndroid;
final bool kIsIOS = !kIsWeb && Platform.isIOS;
final bool kIsMacOS = !kIsWeb && Platform.isMacOS;
final bool kIsWindows = !kIsWeb && Platform.isWindows;
final bool kIsLinux = !kIsWeb && Platform.isLinux;
final bool kIsFuchsia = !kIsWeb && Platform.isFuchsia;

// Additional platform constants
final bool kIsFlatpak =
    kIsLinux && Platform.environment.containsKey('FLATPAK_ID');