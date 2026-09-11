import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:building_utility_management_system/features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import 'package:building_utility_management_system/features/maintenance/data/models/maintenance_request_model.dart';
import 'package:building_utility_management_system/features/maintenance/data/repositories/maintenance_repository_impl.dart';

class MockMaintenanceRemoteDataSource extends Mock implements MaintenanceRemoteDataSource {}

void main() {
  late MockMaintenanceRemoteDataSource mockDataSource;
  late MaintenanceRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockMaintenanceRemoteDataSource();
    repository = MaintenanceRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const tModel = MaintenanceRequestModel(
    id: 1,
    title: 'Test issue',
    description: 'Detailed description',
    category: 'electrical',
    priority: 'medium',
    status: 'open',
    createdAt: '2026-09-11T10:00:00Z',
  );

  test('getRequests returns mapped entities on success', () async {
    when(() => mockDataSource.getRequests(
          flatId: any(named: 'flatId'),
          status: any(named: 'status'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => [tModel]);

    final result = await repository.getRequests(flatId: 5);

    expect(result.isRight(), true);
    result.match(
      (l) => fail('Should be right'),
      (requests) {
        expect(requests.length, 1);
        expect(requests.first.id, 1);
        expect(requests.first.title, 'Test issue');
      },
    );
  });

  test('createRequest returns created entity on success', () async {
    when(() => mockDataSource.createRequest(
          flatId: any(named: 'flatId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          category: any(named: 'category'),
          priority: any(named: 'priority'),
        )).thenAnswer((_) async => tModel);

    final result = await repository.createRequest(
      flatId: 5,
      title: 'Test issue',
      description: 'Detailed description',
      category: 'electrical',
      priority: 'medium',
    );

    expect(result.isRight(), true);
    result.match(
      (l) => fail('Should be right'),
      (created) => expect(created.id, 1),
    );
  });
}
