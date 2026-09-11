import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:building_utility_management_system/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:building_utility_management_system/features/payments/data/models/payment_model.dart';
import 'package:building_utility_management_system/features/payments/data/models/payment_submission_model.dart';
import 'package:building_utility_management_system/features/payments/data/repositories/payments_repository_impl.dart';

class MockPaymentsRemoteDataSource extends Mock implements PaymentsRemoteDataSource {}

void main() {
  late MockPaymentsRemoteDataSource mockDataSource;
  late PaymentsRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPaymentsRemoteDataSource();
    repository = PaymentsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const tPaymentModel = PaymentModel(
    id: 1,
    receiptNo: 'REC-001',
    amount: '2500.00',
    method: 'bkash',
    receivedOn: '2026-09-10',
    receiptUrl: 'http://test/receipt/1',
    createdAt: '2026-09-10T10:00:00Z',
  );

  const tSubmissionModel = PaymentSubmissionModel(
    id: 2,
    amount: '2500.00',
    paymentMethod: 'nagad',
    referenceNumber: 'TX1234',
    paymentDate: '2026-09-10',
    status: 'pending',
    createdAt: '2026-09-10T10:00:00Z',
  );

  test('getPayments returns mapped PaymentEntity list on success', () async {
    when(() => mockDataSource.getPayments(
          flatId: any(named: 'flatId'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => [tPaymentModel]);

    final result = await repository.getPayments(flatId: 10);

    expect(result.isRight(), true);
    result.match(
      (l) => fail('Should be right'),
      (payments) {
        expect(payments.length, 1);
        expect(payments.first.receiptNo, 'REC-001');
      },
    );
  });

  test('submitPayment returns created PaymentSubmissionEntity on success', () async {
    when(() => mockDataSource.submitPayment(
          flatId: any(named: 'flatId'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          referenceNumber: any(named: 'referenceNumber'),
          paymentDate: any(named: 'paymentDate'),
          notes: any(named: 'notes'),
          slipFilePath: any(named: 'slipFilePath'),
        )).thenAnswer((_) async => tSubmissionModel);

    final result = await repository.submitPayment(
      flatId: 10,
      amount: '2500.00',
      method: 'nagad',
      referenceNumber: 'TX1234',
      paymentDate: '2026-09-10',
    );

    expect(result.isRight(), true);
    result.match(
      (l) => fail('Should be right'),
      (submission) {
        expect(submission.id, 2);
        expect(submission.paymentMethod, 'nagad');
      },
    );
  });
}
