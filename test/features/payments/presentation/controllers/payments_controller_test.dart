import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:building_utility_management_system/features/payments/domain/entities/payment_entity.dart';
import 'package:building_utility_management_system/features/payments/domain/entities/payment_submission_entity.dart';
import 'package:building_utility_management_system/features/payments/domain/usecases/get_payment_submissions_usecase.dart';
import 'package:building_utility_management_system/features/payments/domain/usecases/get_payments_usecase.dart';
import 'package:building_utility_management_system/features/payments/domain/usecases/submit_payment_usecase.dart';
import 'package:building_utility_management_system/features/payments/presentation/controllers/payments_controller.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';

class MockGetPaymentsUseCase extends Mock implements GetPaymentsUseCase {}
class MockGetSubmissionsUseCase extends Mock implements GetPaymentSubmissionsUseCase {}
class MockSubmitPaymentUseCase extends Mock implements SubmitPaymentUseCase {}
class MockFlatContextService extends Mock implements FlatContextService {}

void main() {
  late MockGetPaymentsUseCase mockGetPayments;
  late MockGetSubmissionsUseCase mockGetSubmissions;
  late MockSubmitPaymentUseCase mockSubmitPayment;
  late MockFlatContextService mockFlatService;
  late PaymentsController controller;

  const tFlat = FlatEntity(
    id: 10,
    number: '3A',
    floor: '3',
    buildingId: 1,
    buildingName: 'Tower A',
  );

  setUp(() {
    mockGetPayments = MockGetPaymentsUseCase();
    mockGetSubmissions = MockGetSubmissionsUseCase();
    mockSubmitPayment = MockSubmitPaymentUseCase();
    mockFlatService = MockFlatContextService();

    when(() => mockFlatService.selectedFlat)
        .thenReturn(Rx<FlatEntity?>(tFlat));

    controller = PaymentsController(
      getPaymentsUseCase: mockGetPayments,
      getSubmissionsUseCase: mockGetSubmissions,
      submitPaymentUseCase: mockSubmitPayment,
      flatService: mockFlatService,
    );
  });

  test('changeTab updates selectedTabIndex', () {
    expect(controller.selectedTabIndex.value, 0);
    controller.changeTab(1);
    expect(controller.selectedTabIndex.value, 1);
  });

  test('loadPayments populates payments list on success', () async {
    const tPayment = PaymentEntity(
      id: 1,
      receiptNo: 'REC-001',
      amount: '5000.00',
      method: 'bkash',
      reference: 'TX123',
      receivedOn: '2026-09-11',
      receiptUrl: 'http://test/1',
      createdAt: '2026-09-11',
    );

    when(() => mockGetPayments.call(
          flatId: any(named: 'flatId'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right([tPayment]));

    when(() => mockGetSubmissions.call(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => const Right([]));

    await controller.loadData(flatId: 10);

    expect(controller.payments.length, 1);
    expect(controller.payments.first.receiptNo, 'REC-001');
  });
}
