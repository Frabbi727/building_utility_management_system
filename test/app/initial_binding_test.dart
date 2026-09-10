import 'package:building_utility_management_system/app/bootstrap.dart';
import 'package:building_utility_management_system/app/flavors/app_flavor.dart';
import 'package:building_utility_management_system/core/network/dio_client.dart';
import 'package:building_utility_management_system/core/network/network_info.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppFlavor.initialize(
      env: FlavorEnvironment.dev,
      apiBaseUrl: 'https://api.dev.example.com',
      title: 'Test App',
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('InitialBinding', () {
    test('registers SecureStorageService, LocalCacheService, NetworkInfo, and DioClient', () {
      expect(Get.isRegistered<SecureStorageService>(), isFalse);
      expect(Get.isRegistered<LocalCacheService>(), isFalse);
      expect(Get.isRegistered<NetworkInfo>(), isFalse);
      expect(Get.isRegistered<DioClient>(), isFalse);

      InitialBinding().dependencies();

      expect(Get.isRegistered<SecureStorageService>(), isTrue);
      expect(Get.find<SecureStorageService>(), isA<SecureStorageService>());

      expect(Get.isRegistered<LocalCacheService>(), isTrue);
      expect(Get.find<LocalCacheService>(), isA<LocalCacheService>());

      expect(Get.isRegistered<NetworkInfo>(), isTrue);
      expect(Get.find<NetworkInfo>(), isA<NetworkInfo>());

      expect(Get.isRegistered<DioClient>(), isTrue);
      expect(Get.find<DioClient>(), isA<DioClient>());
    });

    test('reuses existing services if already registered prior to binding', () {
      final mockStorage = MockSecureStorageService();
      final mockNetwork = MockNetworkInfo();
      final localCache = LocalCacheService();

      Get.put<SecureStorageService>(mockStorage, permanent: true);
      Get.put<LocalCacheService>(localCache, permanent: true);
      Get.put<NetworkInfo>(mockNetwork, permanent: true);

      InitialBinding().dependencies();

      expect(Get.find<SecureStorageService>(), same(mockStorage));
      expect(Get.find<LocalCacheService>(), same(localCache));
      expect(Get.find<NetworkInfo>(), same(mockNetwork));
      expect(Get.isRegistered<DioClient>(), isTrue);
    });

    test('preserves existing DioClient if already registered', () {
      final mockStorage = MockSecureStorageService();
      final mockNetwork = MockNetworkInfo();
      final existingDio = DioClient(
        baseUrl: 'https://existing.example.com',
        storage: mockStorage,
        networkInfo: mockNetwork,
      );

      Get.put<DioClient>(existingDio, permanent: true);

      InitialBinding().dependencies();

      expect(Get.find<DioClient>(), same(existingDio));
    });
  });
}
