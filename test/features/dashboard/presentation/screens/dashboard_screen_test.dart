import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/widgets/shimmer_loading.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/latest_bill_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/notice_snippet_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/recent_activity_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/resident_balances_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:building_utility_management_system/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:building_utility_management_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDashboardDataUseCase extends Mock
    implements GetDashboardDataUseCase {}

class MockFlatContextService extends Mock implements FlatContextService {}

void main() {
  late MockGetDashboardDataUseCase mockUseCase;
  late MockFlatContextService mockFlatService;
  late DashboardController controller;

  const testFlat = FlatEntity(
    id: 1,
    number: '101-A',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower A',
  );

  const sampleData = DashboardDataEntity(
    flat: testFlat,
    balances: ResidentBalancesEntity(
      totalDue: '5000.00',
      advanceHeld: '0.00',
      currentMonthCharges: '5000.00',
      arrears: '0.00',
    ),
    latestBill: LatestBillEntity(
      id: 10,
      billNo: 'SCB-2026-09-01',
      billingMonth: '2026-09',
      totalAmount: '5000.00',
      dueDate: '2026-09-15',
      status: 'unpaid',
    ),
    activeNotices: [
      NoticeSnippetEntity(
        id: 1,
        title: 'Elevator Maintenance Notice',
        publishedAt: '2026-09-10',
      ),
    ],
    recentActivity: [
      RecentActivityEntity(
        id: 100,
        type: 'payment',
        title: 'Utility Payment Received',
        amount: '5000.00',
        date: '2026-09-05',
        status: 'approved',
      ),
    ],
  );

  setUp(() {
    Get.reset();
    mockUseCase = MockGetDashboardDataUseCase();
    mockFlatService = MockFlatContextService();
    when(() => mockFlatService.selectedFlat).thenReturn(Rx<FlatEntity?>(null));

    controller = DashboardController(
      getDashboardDataUseCase: mockUseCase,
      flatService: mockFlatService,
    );
    Get.put<DashboardController>(controller);
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
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardScreen(),
      ),
    );
  }

  testWidgets('shows DashboardSkeleton when state is LoadingState',
      (tester) async {
    controller.state.value = const LoadingState();

    await tester.pumpWidget(buildTestWidget());
    expect(find.byType(DashboardSkeleton), findsOneWidget);
  });

  testWidgets('shows error message and retry button when state is ErrorState',
      (tester) async {
    controller.state.value = const ErrorState('Network connection error');

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Network connection error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders all sections when state is SuccessState',
      (tester) async {
    controller.state.value = const SuccessState<DashboardDataEntity>(sampleData);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('৳ 5000.00'), findsAtLeast(1));
    expect(find.text('Latest Bill'), findsOneWidget);
    expect(find.text('SCB-2026-09-01'), findsOneWidget);
    expect(find.text('Building Notices'), findsOneWidget);
    expect(find.text('Elevator Maintenance Notice'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('Utility Payment Received'), findsOneWidget);
  });
}
