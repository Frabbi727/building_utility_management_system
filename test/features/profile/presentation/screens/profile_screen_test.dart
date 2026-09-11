import 'package:building_utility_management_system/core/constants/storage_keys.dart';
import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/network/dio_client.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:building_utility_management_system/features/profile/presentation/controllers/profile_controller.dart';
import 'package:building_utility_management_system/features/profile/presentation/screens/profile_screen.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mocktail/mocktail.dart';

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

  const testUser = UserEntity(
    id: '1',
    name: 'Alice Resident',
    email: 'alice@example.com',
    phone: '01711223344',
    isOwner: true,
    isTenant: false,
  );

  const testFlat = FlatEntity(
    id: 1,
    number: '401-A',
    floor: '4th',
    buildingId: 1,
    buildingName: 'Sunrise Towers',
  );

  setUp(() {
    Get.reset();
    Get.testMode = true;

    mockDioClient = MockDioClient();
    mockCache = MockLocalCacheService();
    mockSecureStorage = MockSecureStorageService();
    mockFlatService = MockFlatContextService();
    mockDio = MockDio();

    when(() => mockDioClient.dio).thenReturn(mockDio);
    when(() => mockFlatService.availableFlats).thenReturn(<FlatEntity>[testFlat].obs);
    when(() => mockFlatService.selectedFlat).thenReturn(Rx<FlatEntity?>(testFlat));
    when(() => mockCache.get<String>(StorageKeys.appLocale)).thenReturn('en');
    when(() => mockCache.get<String>(StorageKeys.userProfile)).thenReturn(null);

    controller = ProfileController(
      dioClient: mockDioClient,
      cacheService: mockCache,
      flatService: mockFlatService,
      secureStorageService: mockSecureStorage,
    );
    controller.user.value = testUser;
    Get.put<ProfileController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => const GetMaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen renders user details, assigned flat, and options', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Alice Resident'), findsOneWidget);
    expect(find.text('alice@example.com'), findsOneWidget);
    expect(find.text('01711223344'), findsOneWidget);
    expect(find.text('401-A • Sunrise Towers'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}
