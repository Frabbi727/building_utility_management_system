import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:building_utility_management_system/features/bills/data/datasources/bills_remote_data_source.dart';
import 'package:building_utility_management_system/features/bills/data/models/bill_model.dart';
import 'package:building_utility_management_system/features/bills/data/repositories/bills_repository_impl.dart';

class MockBillsRemoteDataSource extends Mock implements BillsRemoteDataSource {}

void main() {
  late MockBillsRemoteDataSource mockDataSource;
  late BillsRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockBillsRemoteDataSource();
    repository = BillsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const tBillModel = BillModel(
    id: 1,
    billNo: 'BILL-001',
    billingMonth: '2026-09',
    totalAmount: '4500.00',
    dueDate: '2026-09-25',
    status: 'unpaid',
    createdAt: '2026-09-01T00:00:00Z',
  );

  test('getBills returns mapped BillEntity list on success', () async {
    when(() => mockDataSource.getBills(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
          year: any(named: 'year'),
          month: any(named: 'month'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => [tBillModel]);

    final result = await repository.getBills(flatId: 10);

    expect(result.isRight(), true);
    result.match(
      (l) => fail('Should be right'),
      (bills) {
        expect(bills.length, 1);
        expect(bills.first.billNo, 'BILL-001');
      },
    );
  });

  test('getBillDetails returns single BillEntity on success', () async {
    when(() => mockDataSource.getBillDetails(any()))
        .thenAnswer((_) async => tBillModel);

    final result = await repository.getBillDetails(1);

    expect(result.isRight(), true);
    result.match(
      (l) => fail('Should be right'),
      (bill) => expect(bill.id, 1),
    );
  });
}
