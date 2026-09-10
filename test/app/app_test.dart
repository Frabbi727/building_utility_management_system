import 'package:building_utility_management_system/app/app.dart';
import 'package:building_utility_management_system/app/flavors/app_flavor.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockLocalCacheService extends Mock implements LocalCacheService {}

void main() {
  setUp(() {
    AppFlavor.initialize(
      env: FlavorEnvironment.dev,
      apiBaseUrl: 'https://api.dev.example.com',
      title: 'Building Utility Management (Dev)',
    );
    final mockStorage = MockSecureStorageService();
    when(() => mockStorage.hasToken).thenReturn(false);
    Get.put<SecureStorageService>(mockStorage, permanent: true);
    Get.put<LocalCacheService>(MockLocalCacheService(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('MainApp renders LoginScreen as initial route', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
