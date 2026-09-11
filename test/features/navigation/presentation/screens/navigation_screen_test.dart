import 'dart:async';
import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/storage/local_cache_service.dart';
import 'package:building_utility_management_system/features/bills/domain/usecases/get_bill_details_usecase.dart';
import 'package:building_utility_management_system/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:building_utility_management_system/features/bills/presentation/controllers/bills_controller.dart';
import 'package:building_utility_management_system/features/bills/presentation/screens/bills_screen.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/resident_balances_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:building_utility_management_system/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:building_utility_management_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:building_utility_management_system/features/maintenance/domain/usecases/create_maintenance_request_usecase.dart';
import 'package:building_utility_management_system/features/maintenance/domain/usecases/get_maintenance_requests_usecase.dart';
import 'package:building_utility_management_system/features/maintenance/presentation/controllers/maintenance_controller.dart';
import 'package:building_utility_management_system/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:building_utility_management_system/features/navigation/presentation/controllers/navigation_controller.dart';
import 'package:building_utility_management_system/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:building_utility_management_system/features/payments/domain/usecases/get_payment_submissions_usecase.dart';
import 'package:building_utility_management_system/features/payments/domain/usecases/get_payments_usecase.dart';
import 'package:building_utility_management_system/features/payments/domain/usecases/submit_payment_usecase.dart';
import 'package:building_utility_management_system/features/payments/presentation/controllers/payments_controller.dart';
import 'package:building_utility_management_system/features/payments/presentation/screens/payments_screen.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalCacheService extends Mock implements LocalCacheService {}
class MockGetDashboardDataUseCase extends Mock implements GetDashboardDataUseCase {}
class MockGetBillsUseCase extends Mock implements GetBillsUseCase {}
class MockGetBillDetailsUseCase extends Mock implements GetBillDetailsUseCase {}
class MockGetPaymentsUseCase extends Mock implements GetPaymentsUseCase {}
class MockGetSubmissionsUseCase extends Mock implements GetPaymentSubmissionsUseCase {}
class MockSubmitPaymentUseCase extends Mock implements SubmitPaymentUseCase {}
class MockGetMaintenanceRequestsUseCase extends Mock implements GetMaintenanceRequestsUseCase {}
class MockCreateMaintenanceRequestUseCase extends Mock implements CreateMaintenanceRequestUseCase {}

void main() {
  late NavigationController navigationController;
  late MockLocalCacheService mockCacheService;
  late MockGetDashboardDataUseCase mockDashboardUseCase;
  late MockGetBillsUseCase mockGetBillsUseCase;
  late MockGetBillDetailsUseCase mockGetBillDetailsUseCase;
  late MockGetPaymentsUseCase mockGetPaymentsUseCase;
  late MockGetSubmissionsUseCase mockGetSubmissionsUseCase;
  late MockSubmitPaymentUseCase mockSubmitPaymentUseCase;
  late MockGetMaintenanceRequestsUseCase mockGetMaintenanceRequestsUseCase;
  late MockCreateMaintenanceRequestUseCase mockCreateMaintenanceRequestUseCase;
  late FlatContextService flatContextService;
  late DashboardController dashboardController;
  late BillsController billsController;
  late PaymentsController paymentsController;
  late MaintenanceController maintenanceController;

  const testFlat = FlatEntity(
    id: 1,
    number: '101-A',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower One',
  );

  setUp(() {
    Get.reset();
    Get.testMode = true;

    mockCacheService = MockLocalCacheService();
    mockDashboardUseCase = MockGetDashboardDataUseCase();
    mockGetBillsUseCase = MockGetBillsUseCase();
    mockGetBillDetailsUseCase = MockGetBillDetailsUseCase();
    mockGetPaymentsUseCase = MockGetPaymentsUseCase();
    mockGetSubmissionsUseCase = MockGetSubmissionsUseCase();
    mockSubmitPaymentUseCase = MockSubmitPaymentUseCase();
    mockGetMaintenanceRequestsUseCase = MockGetMaintenanceRequestsUseCase();
    mockCreateMaintenanceRequestUseCase = MockCreateMaintenanceRequestUseCase();

    when(() => mockCacheService.getInt(any())).thenReturn(1);
    when(() => mockCacheService.putInt(any(), any())).thenAnswer((_) async => true);

    const sampleData = DashboardDataEntity(
      flat: testFlat,
      balances: ResidentBalancesEntity(
        totalDue: '5000.00',
        advanceHeld: '0.00',
        currentMonthCharges: '5000.00',
        arrears: '0.00',
      ),
      activeNotices: [],
      recentActivity: [],
    );
    when(() => mockDashboardUseCase(flatId: any(named: 'flatId')))
        .thenAnswer((_) async => const Right(sampleData));
    when(() => mockGetBillsUseCase(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => const Right([]));
    when(() => mockGetPaymentsUseCase(flatId: any(named: 'flatId')))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetSubmissionsUseCase(flatId: any(named: 'flatId')))
        .thenAnswer((_) async => const Right([]));
    when(() => mockGetMaintenanceRequestsUseCase(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => const Right([]));

    flatContextService = FlatContextService(cacheService: mockCacheService);
    flatContextService.initializeFlats([testFlat]);
    Get.put<FlatContextService>(flatContextService);

    dashboardController = DashboardController(
      getDashboardDataUseCase: mockDashboardUseCase,
      flatService: flatContextService,
    );
    Get.put<DashboardController>(dashboardController);

    billsController = BillsController(
      getBillsUseCase: mockGetBillsUseCase,
      getBillDetailsUseCase: mockGetBillDetailsUseCase,
      flatService: flatContextService,
    );
    Get.put<BillsController>(billsController);

    paymentsController = PaymentsController(
      getPaymentsUseCase: mockGetPaymentsUseCase,
      getSubmissionsUseCase: mockGetSubmissionsUseCase,
      submitPaymentUseCase: mockSubmitPaymentUseCase,
      flatService: flatContextService,
    );
    Get.put<PaymentsController>(paymentsController);

    maintenanceController = MaintenanceController(
      getRequestsUseCase: mockGetMaintenanceRequestsUseCase,
      createRequestUseCase: mockCreateMaintenanceRequestUseCase,
      flatService: flatContextService,
    );
    Get.put<MaintenanceController>(maintenanceController);

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

  testWidgets('renders NavigationBar with all 4 tab destinations', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Home')),
        findsOneWidget);
    expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Bills')),
        findsOneWidget);
    expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Payments')),
        findsOneWidget);
    expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Maintenance')),
        findsOneWidget);
  });

  testWidgets('displays selected flat in app bar chip', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('101-A • Tower One'), findsOneWidget);
  });

  testWidgets('switching tab updates navigation controller and views', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 0);
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Tap Bills destination
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('Bills')));
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 1);
    expect(find.byType(BillsScreen), findsOneWidget);

    // Tap Payments destination
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('Payments')));
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 2);
    expect(find.byType(PaymentsScreen), findsOneWidget);

    // Tap Maintenance destination
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('Maintenance')));
    await tester.pumpAndSettle();

    expect(navigationController.currentIndex.value, 3);
    expect(find.byType(MaintenanceScreen), findsOneWidget);
  });

  testWidgets('navigating to another screen does not throw Hero tag conflict', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    unawaited(Get.to<dynamic>(() => const Scaffold(body: Text('Dummy Page'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
