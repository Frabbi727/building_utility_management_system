import 'package:building_utility_management_system/app/flavors/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavor', () {
    test('initializes with dev environment', () {
      AppFlavor.initialize(
        env: FlavorEnvironment.dev,
        apiBaseUrl: 'https://api.dev.example.com',
        title: 'Building Utility Management (Dev)',
      );

      expect(AppFlavor.environment, equals(FlavorEnvironment.dev));
      expect(AppFlavor.baseUrl, equals('https://api.dev.example.com'));
      expect(AppFlavor.appName, equals('Building Utility Management (Dev)'));
    });

    test('initializes with staging environment', () {
      AppFlavor.initialize(
        env: FlavorEnvironment.staging,
        apiBaseUrl: 'https://api.staging.example.com',
        title: 'Building Utility Management (Staging)',
      );

      expect(AppFlavor.environment, equals(FlavorEnvironment.staging));
      expect(AppFlavor.baseUrl, equals('https://api.staging.example.com'));
      expect(AppFlavor.appName, equals('Building Utility Management (Staging)'));
    });

    test('initializes with prod environment', () {
      AppFlavor.initialize(
        env: FlavorEnvironment.prod,
        apiBaseUrl: 'https://api.example.com',
        title: 'Building Utility Management',
      );

      expect(AppFlavor.environment, equals(FlavorEnvironment.prod));
      expect(AppFlavor.baseUrl, equals('https://api.example.com'));
      expect(AppFlavor.appName, equals('Building Utility Management'));
    });
  });
}
