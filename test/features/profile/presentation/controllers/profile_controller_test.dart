import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:building_utility_management_system/core/constants/api_endpoints.dart';
import 'package:building_utility_management_system/core/constants/storage_keys.dart';
import 'package:building_utility_management_system/core/network/dio_client.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:building_utility_management_system/features/profile/presentation/controllers/profile_controller.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';

class MockDioClient extends Mock implements DioClient {}
class MockLocalCacheService extends Mock implements LocalCacheService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockFlatContextService extends Mock implements FlatContextService {}
class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockLocalCacheService mockCache;
  late MockSecureStorageService mockSecureStorage;
  late MockFlatContextService mockFlatService;
  late MockDio mockDio;
  late ProfileController controller;

  setUp(() {
    Get.testMode = true;
    mockDioClient = MockDioClient();
    mockCache = MockLocalCacheService();
    mockSecureStorage = MockSecureStorageService();
    mockFlatService = MockFlatContextService();
    mockDio = MockDio();

    when(() => mockDioClient.dio).thenReturn(mockDio);
    when(() => mockFlatService.availableFlats).thenReturn(<FlatEntity>[].obs);
    when(() => mockCache.get<String>(StorageKeys.appLocale)).thenReturn('en');
    when(() => mockCache.get<String>(StorageKeys.userProfile)).thenReturn(null);

    controller = ProfileController(
      dioClient: mockDioClient,
      cacheService: mockCache,
      flatService: mockFlatService,
      secureStorageService: mockSecureStorage,
    );
  });

  group('ProfileController', () {
    test('changePassword sends POST request and returns true on success', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
            ApiEndpoints.changePassword,
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.changePassword),
            statusCode: 200,
            data: {'status': 'success', 'message': 'Password updated'},
          ));

      final result = await controller.changePassword(
        currentPassword: 'oldpassword',
        newPassword: 'newpassword123',
        confirmPassword: 'newpassword123',
      );

      expect(result, true);
      verify(() => mockDio.post<Map<String, dynamic>>(
            ApiEndpoints.changePassword,
            data: {
              'current_password': 'oldpassword',
              'new_password': 'newpassword123',
              'new_password_confirmation': 'newpassword123',
            },
          )).called(1);
    });

    test('changePassword returns false when passwords do not match', () async {
      final result = await controller.changePassword(
        currentPassword: 'oldpassword',
        newPassword: 'newpassword123',
        confirmPassword: 'differentpassword',
      );

      expect(result, false);
      expect(controller.errorMessage.value, isNotNull);
      verifyNever(() => mockDio.post<Map<String, dynamic>>(any(), data: any(named: 'data')));
    });

    test('fetchProfile sets user from ApiEndpoints.me response', () async {
      when(() => mockDio.get<Map<String, dynamic>>(ApiEndpoints.me)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.me),
          statusCode: 200,
          data: {
            'status': 'success',
            'data': {
              'user': {
                'id': 1,
                'name': 'John Doe',
                'email': 'john@example.com',
                'phone': '01700000000',
                'is_owner': true,
                'is_tenant': false,
              },
              'flats': <dynamic>[],
            },
          },
        ),
      );
      when(() => mockCache.put<String>(StorageKeys.userProfile, any())).thenAnswer((_) async {});

      await controller.fetchProfile();

      expect(controller.user.value?.name, 'John Doe');
      expect(controller.user.value?.email, 'john@example.com');
      expect(controller.user.value?.phone, '01700000000');
    });

    test('switchLanguage updates cache and observable', () async {
      when(() => mockCache.put<String>(StorageKeys.appLocale, 'bn')).thenAnswer((_) async {});

      await controller.switchLanguage(const Locale('bn'));

      expect(controller.currentLocale.value, const Locale('bn'));
      verify(() => mockCache.put<String>(StorageKeys.appLocale, 'bn')).called(1);
    });

    test('logout clears secure storage, flat service, and cache', () async {
      when(() => mockDio.post<dynamic>(ApiEndpoints.logout)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.logout),
          statusCode: 200,
        ),
      );
      when(() => mockSecureStorage.clearTokens()).thenAnswer((_) async {});
      when(() => mockCache.delete(StorageKeys.userProfile)).thenAnswer((_) async {});
      when(() => mockFlatService.clear()).thenReturn(null);

      await controller.logout();

      verify(() => mockSecureStorage.clearTokens()).called(1);
      verify(() => mockFlatService.clear()).called(1);
      verify(() => mockCache.delete(StorageKeys.userProfile)).called(1);
    });
  });
}
