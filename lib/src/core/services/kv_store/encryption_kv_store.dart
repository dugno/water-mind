import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:water_mind/src/common/constant/platform.dart';

abstract class EncryptedKVStoreService {
  static const _storage = FlutterSecureStorage(
    // iOSOptions(accessibility: IOSAccessibility.first_unlock)
  );

  static FlutterSecureStorage get storage => _storage;
  static bool get isUnSupportedPlatform =>
      kIsMacOS || kIsIOS || (kIsLinux && !kIsFlatpak);
}