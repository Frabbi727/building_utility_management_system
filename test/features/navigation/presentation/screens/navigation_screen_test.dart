import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/features/navigation/presentation/controllers/navigation_controller.dart';
import 'package:building_utility_management_system/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalCacheService extends Mock implements LocalCacheService {}

void main() {
  late NavigationController navigationController;
  late MockLocalCacheService mockCacheService;
  late FlatContextService flatContextService;

  const testFlat = FlatEntity(
    id: 1,
    number: '101-A',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower One',
  );

  setUp(() {
    Get.reset();
    mockCacheService = MockLocalCacheService();
    when(() => mockCacheService.getInt(any())).thenReturn(1);
    when(() => mockCacheService.putInt(any(), any()))
        .thenAnswer((_) async => true);

    flatContextService = FlatContextService(cacheService: mockCacheService);
    flatContextService.initializeFlats([testFlat]);
    Get.put<FlatContextService>(flatContextService);

    navigationController = NavigationController();
    Get.put<NavigationController>(navigationController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const GetMaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: NavigationScreen(),
      ),
    );
  }

  testWidgets('renders NavigationBar with all 4 tab destinations',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Maintenance'), findsOneWidget);
  });

  testWidgets('displays selected flat in app bar chip', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('101-A • Tower One'), findsOneWidget);
  });

  testWidgets('switching tab updates navigation controller and views',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 0);
    expect(find.text('Dashboard View'), findsOneWidget);

    // Tap Bills destination
    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 1);
    expect(find.text('Bills'), findsAtLeast(1));

    // Tap Payments destination
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 2);

    // Tap Maintenance destination
    await tester.tap(find.text('Maintenance'));
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 3);
  });
}
