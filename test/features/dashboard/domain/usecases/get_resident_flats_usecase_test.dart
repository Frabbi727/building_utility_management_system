import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:building_utility_management_system/features/dashboard/domain/usecases/get_resident_flats_usecase.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;
  late GetResidentFlatsUseCase useCase;

  const sampleFlats = [
    FlatEntity(
      id: 1,
      number: 'A-101',
      floor: '1st',
      buildingId: 10,
      buildingName: 'Tower A',
    ),
    FlatEntity(
      id: 2,
      number: 'B-202',
      floor: '2nd',
      buildingId: 10,
      buildingName: 'Tower B',
    ),
  ];

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetResidentFlatsUseCase(mockRepository);
  });

  test('should return Right(List<FlatEntity>) when repository succeeds', () async {
    when(() => mockRepository.getResidentFlats())
        .thenAnswer((_) async => const Right<Failure, List<FlatEntity>>(sampleFlats));

    final result = await useCase();

    expect(result, equals(const Right<Failure, List<FlatEntity>>(sampleFlats)));
    verify(() => mockRepository.getResidentFlats()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Left(ServerFailure) when repository fails', () async {
    const failure = ServerFailure('Failed to load flats');
    when(() => mockRepository.getResidentFlats())
        .thenAnswer((_) async => const Left<Failure, List<FlatEntity>>(failure));

    final result = await useCase();

    expect(result, equals(const Left<Failure, List<FlatEntity>>(failure)));
    verify(() => mockRepository.getResidentFlats()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
