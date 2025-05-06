import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'firebase_remote_config_test.mocks.dart';
import 'firebase_remote_config_test_service.dart';

@GenerateMocks([FirebaseRemoteConfig])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseRemoteConfigService', () {
    late MockFirebaseRemoteConfig mockRemoteConfig;

    setUp(() {
      mockRemoteConfig = MockFirebaseRemoteConfig();
    });

    test('getWeatherApiKey returns value from remote config', () {
      // Arrange
      const expectedApiKey = 'test_api_key';
      when(mockRemoteConfig.getString('key_weatherapi')).thenReturn(expectedApiKey);

      // Create service with mock
      final service = TestFirebaseRemoteConfigService(mockRemoteConfig);

      // Act
      final result = service.getWeatherApiKey();

      // Assert
      expect(result, equals(expectedApiKey));
    });

    test('getAllValues returns map with all config values', () {
      // Arrange
      const expectedApiKey = 'test_api_key';
      when(mockRemoteConfig.getString('key_weatherapi')).thenReturn(expectedApiKey);

      // Create service with mock
      final service = TestFirebaseRemoteConfigService(mockRemoteConfig);

      // Act
      final result = service.getAllValues();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['key_weatherapi'], equals(expectedApiKey));
    });

    test('refreshConfig handles fetch and activate separately', () async {
      // Arrange
      when(mockRemoteConfig.fetch()).thenAnswer((_) async {});
      when(mockRemoteConfig.activate()).thenAnswer((_) async => true);

      final service = TestFirebaseRemoteConfigService(mockRemoteConfig);

      // Act
      final result = await service.refreshConfig();

      // Assert
      verify(mockRemoteConfig.fetch()).called(1);
      verify(mockRemoteConfig.activate()).called(1);
      expect(result, isTrue);
    });

    test('refreshConfig handles fetch error gracefully', () async {
      // Arrange
      when(mockRemoteConfig.fetch()).thenThrow(Exception('Cannot parse response'));

      final service = TestFirebaseRemoteConfigService(mockRemoteConfig);

      // Act
      final result = await service.refreshConfig();

      // Assert
      verify(mockRemoteConfig.fetch()).called(1);
      verifyNever(mockRemoteConfig.activate());
      expect(result, isFalse);
    });

    test('create method handles fetchAndActivate error by using separate fetch and activate', () async {
      // This test simulates the PlatformException scenario
      // Arrange
      when(mockRemoteConfig.fetchAndActivate())
          .thenThrow(Exception('PlatformException: cannot parse response'));
      when(mockRemoteConfig.fetch()).thenAnswer((_) async {});
      when(mockRemoteConfig.activate()).thenAnswer((_) async => true);

      // We can't directly test the static create method, but we can verify
      // that our implementation in refreshConfig works correctly
      final service = TestFirebaseRemoteConfigService(mockRemoteConfig);

      // Act
      final result = await service.refreshConfig();

      // Assert
      expect(result, isTrue);
    });
  });
}
