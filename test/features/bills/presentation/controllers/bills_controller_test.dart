import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:building_utility_management_system/features/bills/domain/entities/bill_entity.dart';
import 'package:building_utility_management_system/features/bills/domain/usecases/get_bill_details_usecase.dart';
import 'package:building_utility_management_system/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:building_utility_management_system/features/bills/presentation/controllers/bills_controller.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';

class MockGetBillsUseCase extends Mock implements GetBillsUseCase {}
class MockGetBillDetailsUseCase extends Mock implements GetBillDetailsUseCase {}
class MockFlatContextService extends Mock implements FlatContextService {}

void main() {
  late MockGetBillsUseCase mockGetBills;
  late MockGetBillDetailsUseCase mockGetBillDetails;
  late MockFlatContextService mockFlatService;
  late BillsController controller;

  const tFlat = FlatEntity(
    id: 10,
    number: '3A',
    floor: '3',
    buildingId: 1,
    buildingName: 'Tower A',
  );

  const tBill = BillEntity(
    id: 1,
    billNo: 'BILL-001',
    billingMonth: '2026-09',
    totalAmount: '4500.00',
    dueDate: '2026-09-25',
    status: BillStatus.unpaid,
    createdAt: '2026-09-01',
  );

  setUp(() {
    mockGetBills = MockGetBillsUseCase();
    mockGetBillDetails = MockGetBillDetailsUseCase();
    mockFlatService = MockFlatContextService();

    when(() => mockFlatService.selectedFlat)
        .thenReturn(Rx<FlatEntity?>(tFlat));

    controller = BillsController(
      getBillsUseCase: mockGetBills,
      getBillDetailsUseCase: mockGetBillDetails,
      flatService: mockFlatService,
    );
  });

  test('filterByStatus updates selectedStatus and reloads bills', () async {
    when(() => mockGetBills.call(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
          year: any(named: 'year'),
          month: any(named: 'month'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right([tBill]));

    await controller.filterByStatus('unpaid');

    expect(controller.selectedStatus.value, 'unpaid');
    expect(controller.bills.length, 1);
  });
}
