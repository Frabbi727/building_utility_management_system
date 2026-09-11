import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:building_utility_management_system/features/maintenance/domain/entities/maintenance_request_entity.dart';
import 'package:building_utility_management_system/features/maintenance/domain/usecases/create_maintenance_request_usecase.dart';
import 'package:building_utility_management_system/features/maintenance/domain/usecases/get_maintenance_requests_usecase.dart';
import 'package:building_utility_management_system/features/maintenance/presentation/controllers/maintenance_controller.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';

class MockGetMaintenanceRequestsUseCase extends Mock
    implements GetMaintenanceRequestsUseCase {}

class MockCreateMaintenanceRequestUseCase extends Mock
    implements CreateMaintenanceRequestUseCase {}

class MockFlatContextService extends Mock implements FlatContextService {}

void main() {
  late MockGetMaintenanceRequestsUseCase mockGetUC;
  late MockCreateMaintenanceRequestUseCase mockCreateUC;
  late MockFlatContextService mockFlatService;
  late MaintenanceController controller;

  const tRequest = MaintenanceRequestEntity(
    id: 1,
    title: 'Water leaking',
    description: 'Faucet broken',
    category: MaintenanceCategory.plumbing,
    priority: MaintenancePriority.medium,
    status: MaintenanceStatus.open,
    createdAt: '2026-09-11',
  );

  const tFlat = FlatEntity(
    id: 10,
    number: '3A',
    floor: '3',
    buildingId: 1,
    buildingName: 'Tower A',
  );

  setUp(() {
    mockGetUC = MockGetMaintenanceRequestsUseCase();
    mockCreateUC = MockCreateMaintenanceRequestUseCase();
    mockFlatService = MockFlatContextService();

    when(() => mockFlatService.selectedFlat)
        .thenReturn(Rx<FlatEntity?>(tFlat));

    controller = MaintenanceController(
      getRequestsUseCase: mockGetUC,
      createRequestUseCase: mockCreateUC,
      flatService: mockFlatService,
    );
  });

  test('loadRequests sets SuccessState when data returned', () async {
    when(() => mockGetUC.call(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right([tRequest]));

    await controller.loadRequests(flatId: 10);

    expect(controller.state.value, isA<SuccessState<List<MaintenanceRequestEntity>>>());
    expect(controller.requests.length, 1);
  });

  test('filterByStatus updates selectedStatus and reloads', () async {
    when(() => mockGetUC.call(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right([tRequest]));

    await controller.filterByStatus('open');

    expect(controller.selectedStatus.value, 'open');
  });
}
