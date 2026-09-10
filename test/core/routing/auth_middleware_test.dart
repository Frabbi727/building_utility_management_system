import 'package:building_utility_management_system/core/routing/auth_middleware.dart';
import 'package:building_utility_management_system/core/routing/route_names.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;
  late AuthMiddleware middleware;

  setUp(() {
    mockStorage = MockSecureStorageService();
    Get.put<SecureStorageService>(mockStorage);
    middleware = AuthMiddleware();
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthMiddleware', () {
    test('redirect returns null when target route is login regardless of token status', () {
      final result = middleware.redirect(AppRoutes.login);

      expect(result, isNull);
      verifyNever(() => mockStorage.hasToken);
    });

    test('redirect returns null when target route is login with query parameters regardless of token status', () {
      final result = middleware.redirect('${AppRoutes.login}?redirect=${AppRoutes.home}');

      expect(result, isNull);
      verifyNever(() => mockStorage.hasToken);
    });

    test('redirect redirects to login when token is missing', () {
      when(() => mockStorage.hasToken).thenReturn(false);

      final result = middleware.redirect(AppRoutes.home);

      expect(result, isNotNull);
      expect(result!.name, equals(AppRoutes.login));
      verify(() => mockStorage.hasToken).called(1);
    });

    test('redirect returns null when token is present', () {
      when(() => mockStorage.hasToken).thenReturn(true);

      final result = middleware.redirect(AppRoutes.home);

      expect(result, isNull);
      verify(() => mockStorage.hasToken).called(1);
    });

    test('redirect redirects to login when accessing custom protected route without token', () {
      when(() => mockStorage.hasToken).thenReturn(false);

      final result = middleware.redirect('/dashboard/settings');

      expect(result, isNotNull);
      expect(result!.name, equals(AppRoutes.login));
      verify(() => mockStorage.hasToken).called(1);
    });
  });
}
