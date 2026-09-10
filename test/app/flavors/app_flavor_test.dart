import 'package:building_utility_management_system/app/flavors/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavor', () {
    tearDown(() {
      AppFlavor.reset();
    });

    test('throws StateError when accessed before initialization', () {
      expect(
        () => AppFlavor.environment,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'AppFlavor not initialized',
          ),
        ),
      );
      expect(
        () => AppFlavor.baseUrl,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'AppFlavor not initialized',
          ),
        ),
      );
      expect(
        () => AppFlavor.appName,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'AppFlavor not initialized',
          ),
        ),
      );
      expect(AppFlavor.isDev, isFalse);
      expect(AppFlavor.isStaging, isFalse);
      expect(AppFlavor.isProd, isFalse);
    });

    test('initializes with dev environment and helper getters reflect dev', () {
      AppFlavor.initialize(
        env: FlavorEnvironment.dev,
        apiBaseUrl: 'https://api.dev.example.com',
        title: 'Building Utility Management (Dev)',
      );

      expect(AppFlavor.environment, equals(FlavorEnvironment.dev));
      expect(AppFlavor.baseUrl, equals('https://api.dev.example.com'));
      expect(AppFlavor.appName, equals('Building Utility Management (Dev)'));
      expect(AppFlavor.isDev, isTrue);
      expect(AppFlavor.isStaging, isFalse);
      expect(AppFlavor.isProd, isFalse);
    });

    test('initializes with staging environment and helper getters reflect staging', () {
      AppFlavor.initialize(
        env: FlavorEnvironment.staging,
        apiBaseUrl: 'https://api.staging.example.com',
        title: 'Building Utility Management (Staging)',
      );

      expect(AppFlavor.environment, equals(FlavorEnvironment.staging));
      expect(AppFlavor.baseUrl, equals('https://api.staging.example.com'));
      expect(AppFlavor.appName, equals('Building Utility Management (Staging)'));
      expect(AppFlavor.isDev, isFalse);
      expect(AppFlavor.isStaging, isTrue);
      expect(AppFlavor.isProd, isFalse);
    });

    test('initializes with prod environment and helper getters reflect prod', () {
      AppFlavor.initialize(
        env: FlavorEnvironment.prod,
        apiBaseUrl: 'https://api.example.com',
        title: 'Building Utility Management',
      );

      expect(AppFlavor.environment, equals(FlavorEnvironment.prod));
      expect(AppFlavor.baseUrl, equals('https://api.example.com'));
      expect(AppFlavor.appName, equals('Building Utility Management'));
      expect(AppFlavor.isDev, isFalse);
      expect(AppFlavor.isStaging, isFalse);
      expect(AppFlavor.isProd, isTrue);
    });
  });
}
