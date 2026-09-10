import 'package:building_utility_management_system/core/error/exceptions.dart';
import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:building_utility_management_system/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:building_utility_management_system/features/dashboard/data/models/resident_balances_model.dart';
import 'package:building_utility_management_system/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:building_utility_management_system/shared/data/models/flat_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRemoteDataSource extends Mock implements DashboardRemoteDataSource {}

void main() {
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late DashboardRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    repository = DashboardRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const flatModel = FlatModel(
    id: 1,
    number: 'A-101',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower A',
  );

  const balancesModel = ResidentBalancesModel(
    totalDue: '5000.00',
    advanceHeld: '0.00',
    currentMonthCharges: '5000.00',
    arrears: '0.00',
  );

  const dashboardModel = DashboardDataModel(
    flat: flatModel,
    balances: balancesModel,
    latestBill: null,
    activeNotices: [],
    recentActivity: [],
  );

  group('getDashboardData', () {
    test('returns Right(DashboardDataEntity) when remote call succeeds', () async {
      when(() => mockRemoteDataSource.getDashboardData(flatId: 1))
          .thenAnswer((_) async => dashboardModel);

      final result = await repository.getDashboardData(flatId: 1);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not be failure'),
        (entity) => expect(entity, equals(dashboardModel.toEntity())),
      );
      verify(() => mockRemoteDataSource.getDashboardData(flatId: 1)).called(1);
    });

    test('returns Left(Failure) when DioException carries custom Failure', () async {
      const customFailure = AuthFailure('Unauthorized');
      when(() => mockRemoteDataSource.getDashboardData(flatId: 1)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/resident/dashboard'),
          error: customFailure,
        ),
      );

      final result = await repository.getDashboardData(flatId: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, equals(customFailure)),
        (_) => fail('Should not be Right'),
      );
    });

    test('returns Left(ServerFailure) when DioException does not carry Failure', () async {
      when(() => mockRemoteDataSource.getDashboardData(flatId: 1)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/resident/dashboard'),
          message: 'Connection timed out',
        ),
      );

      final result = await repository.getDashboardData(flatId: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be Right'),
      );
    });

    test('returns Left(ServerFailure) when generic Exception is thrown', () async {
      when(() => mockRemoteDataSource.getDashboardData(flatId: 1))
          .thenThrow(const ServerException('Unexpected error'));

      final result = await repository.getDashboardData(flatId: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be Right'),
      );
    });
  });

  group('getResidentFlats', () {
    test('returns Right(List<FlatEntity>) when remote call succeeds', () async {
      when(() => mockRemoteDataSource.getResidentFlats())
          .thenAnswer((_) async => [flatModel]);

      final result = await repository.getResidentFlats();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not be failure'),
        (flats) {
          expect(flats.length, 1);
          expect(flats.first, equals(flatModel.toEntity()));
        },
      );
      verify(() => mockRemoteDataSource.getResidentFlats()).called(1);
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => mockRemoteDataSource.getResidentFlats())
          .thenThrow(Exception('Flats fetch failed'));

      final result = await repository.getResidentFlats();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should not be Right'),
      );
    });
  });
}
