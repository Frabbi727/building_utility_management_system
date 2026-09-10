import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/latest_bill_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/notice_snippet_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/recent_activity_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/resident_balances_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:building_utility_management_system/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;
  late GetDashboardDataUseCase useCase;

  const sampleBalances = ResidentBalancesEntity(
    totalDue: '5000.00',
    advanceHeld: '0.00',
    currentMonthCharges: '5000.00',
    arrears: '0.00',
  );

  const sampleBill = LatestBillEntity(
    id: 10,
    billNo: 'SCB-2026-09-01',
    billingMonth: '2026-09',
    totalAmount: '5000.00',
    dueDate: '2026-09-15',
    status: 'unpaid',
  );

  const sampleNotice = NoticeSnippetEntity(
    id: 1,
    title: 'Water shutdown notice',
    content: 'Water supply will be paused from 10 AM to 1 PM',
    publishedAt: '2026-09-10',
  );

  const sampleActivity = RecentActivityEntity(
    id: 1,
    type: 'payment',
    title: 'Utility Payment',
    amount: '5000.00',
    date: '2026-09-08',
    status: 'approved',
  );

  const sampleFlat = FlatEntity(
    id: 1,
    number: 'A-101',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower',
  );

  const sampleData = DashboardDataEntity(
    flat: sampleFlat,
    balances: sampleBalances,
    latestBill: sampleBill,
    activeNotices: [sampleNotice],
    recentActivity: [sampleActivity],
  );

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardDataUseCase(mockRepository);
  });

  test('should return Right(DashboardDataEntity) when repository succeeds', () async {
    when(() => mockRepository.getDashboardData(flatId: 1))
        .thenAnswer((_) async => const Right<Failure, DashboardDataEntity>(sampleData));

    final result = await useCase(flatId: 1);

    expect(result, equals(const Right<Failure, DashboardDataEntity>(sampleData)));
    verify(() => mockRepository.getDashboardData(flatId: 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Left(ServerFailure) when repository fails', () async {
    const failure = ServerFailure('Server error');
    when(() => mockRepository.getDashboardData(flatId: 1))
        .thenAnswer((_) async => const Left<Failure, DashboardDataEntity>(failure));

    final result = await useCase(flatId: 1);

    expect(result, equals(const Left<Failure, DashboardDataEntity>(failure)));
    verify(() => mockRepository.getDashboardData(flatId: 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
