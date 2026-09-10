import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/latest_bill_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/notice_snippet_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/recent_activity_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/resident_balances_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:building_utility_management_system/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
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
        title: 'Maintenance notice',
        publishedAt: '2026-09-10',
      ),
    ],
    recentActivity: [
      RecentActivityEntity(
        id: 100,
        type: 'payment',
        title: 'Payment',
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
  });

  tearDown(() {
    Get.reset();
  });

  test('loadDashboard sets SuccessState on success', () async {
    when(() => mockUseCase(flatId: 1))
        .thenAnswer((_) async => const Right(sampleData));

    controller = DashboardController(
      getDashboardDataUseCase: mockUseCase,
      flatService: mockFlatService,
    );

    await controller.loadDashboard(flatId: 1);

    expect(controller.state.value, isA<SuccessState<DashboardDataEntity>>());
    final state = controller.state.value as SuccessState<DashboardDataEntity>;
    expect(state.data, equals(sampleData));
    verify(() => mockUseCase(flatId: 1)).called(1);
  });

  test('loadDashboard sets ErrorState on failure', () async {
    when(() => mockUseCase(flatId: 1))
        .thenAnswer((_) async => const Left(ServerFailure('API error')));

    controller = DashboardController(
      getDashboardDataUseCase: mockUseCase,
      flatService: mockFlatService,
    );

    await controller.loadDashboard(flatId: 1);

    expect(controller.state.value, isA<ErrorState>());
    final state = controller.state.value as ErrorState;
    expect(state.message, equals('API error'));
  });

  test('refreshDashboard re-fetches data for selected flat', () async {
    when(() => mockFlatService.selectedFlat)
        .thenReturn(Rx<FlatEntity?>(testFlat));
    when(() => mockUseCase(flatId: 1))
        .thenAnswer((_) async => const Right(sampleData));

    controller = DashboardController(
      getDashboardDataUseCase: mockUseCase,
      flatService: mockFlatService,
    );

    await controller.refreshDashboard();

    expect(controller.state.value, isA<SuccessState<DashboardDataEntity>>());
    verify(() => mockUseCase(flatId: 1)).called(1);
  });
}
