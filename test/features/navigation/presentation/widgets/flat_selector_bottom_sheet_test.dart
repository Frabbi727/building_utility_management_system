import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/features/navigation/presentation/widgets/flat_selector_bottom_sheet.dart';
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
  late MockLocalCacheService mockCacheService;
  late FlatContextService flatContextService;

  const flat1 = FlatEntity(
    id: 1,
    number: '101-A',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower A',
  );

  const flat2 = FlatEntity(
    id: 2,
    number: '202-B',
    floor: '2nd',
    buildingId: 10,
    buildingName: 'Tower A',
  );

  setUp(() {
    Get.reset();
    mockCacheService = MockLocalCacheService();
    when(() => mockCacheService.getInt(any())).thenReturn(1);
    when(() => mockCacheService.putInt(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockCacheService.delete(any()))
        .thenAnswer((_) async => true);

    flatContextService = FlatContextService(cacheService: mockCacheService);
    flatContextService.initializeFlats([flat1, flat2]);
    Get.put<FlatContextService>(flatContextService);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestWidget({Widget? child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: child ??
              Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => FlatSelectorBottomSheet.show(ctx),
                  child: const Text('Open Sheet'),
                ),
              ),
        ),
      ),
    );
  }

  testWidgets('renders all available flats and checkmark on selected flat',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(child: const FlatSelectorBottomSheet()));
    await tester.pumpAndSettle();

    expect(find.text('Select Flat'), findsOneWidget);
    expect(find.text('101-A'), findsOneWidget);
    expect(find.text('202-B'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('tapping another flat calls selectFlat and closes sheet',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Select Flat'), findsOneWidget);

    // Tap second flat
    await tester.tap(find.text('202-B'));
    await tester.pumpAndSettle();

    // Flat should now be selected
    expect(flatContextService.selectedFlat.value?.id, 2);
    // Sheet should be dismissed
    expect(find.text('Select Flat'), findsNothing);
  });

  testWidgets('displays noFlatsAssigned when availableFlats is empty',
      (tester) async {
    flatContextService.clear();

    await tester.pumpWidget(buildTestWidget(child: const FlatSelectorBottomSheet()));
    await tester.pumpAndSettle();

    expect(find.text('No flats assigned'), findsOneWidget);
  });
}
