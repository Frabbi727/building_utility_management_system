import 'package:building_utility_management_system/core/error/exceptions.dart';
import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:building_utility_management_system/features/auth/data/models/auth_response_model.dart';
import 'package:building_utility_management_system/features/auth/data/models/user_model.dart';
import 'package:building_utility_management_system/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:building_utility_management_system/shared/data/models/flat_model.dart';
import 'package:building_utility_management_system/shared/services/flat_context_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockFlatContextService extends Mock implements FlatContextService {
  @override
  InternalFinalCallback<void> get onStart =>
      InternalFinalCallback<void>(callback: () {});
  @override
  InternalFinalCallback<void> get onDelete =>
      InternalFinalCallback<void>(callback: () {});
}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockFlatContextService mockFlatContextService;
  late AuthRepositoryImpl repository;

  setUp(() {
    Get.reset();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockFlatContextService = MockFlatContextService();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      flatContextService: mockFlatContextService,
    );
  });

  tearDown(() {
    Get.reset();
  });

  const email = 'test@example.com';
  const password = 'securePassword123';
  const userModel = UserModel(
    id: 'user-001',
    name: 'Jane Doe',
    email: email,
  );
  const flatModel = FlatModel(
    id: 1,
    number: 'A-101',
    floor: '1st',
    buildingId: 10,
    buildingName: 'Tower A',
  );
  const responseModel = AuthResponseModel(
    token: 'sanctum-token-123',
    user: userModel,
    flats: [flatModel],
  );

  test('login saves tokens, forwards flats to FlatContextService, and returns Right(UserEntity) on success', () async {
    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenAnswer((_) async => responseModel);
    when(
      () => mockLocalDataSource.saveTokens(
        accessToken: responseModel.token,
        refreshToken: responseModel.token,
      ),
    ).thenAnswer((_) async {});
    when(() => mockFlatContextService.initializeFlats(any())).thenReturn(null);

    final result = await repository.login(email: email, password: password);

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Should not be failure'),
      (entity) => expect(entity, equals(userModel.toEntity())),
    );

    verify(() => mockRemoteDataSource.login(email: email, password: password)).called(1);
    verify(
      () => mockLocalDataSource.saveTokens(
        accessToken: 'sanctum-token-123',
        refreshToken: 'sanctum-token-123',
      ),
    ).called(1);
    verify(
      () => mockFlatContextService.initializeFlats([flatModel.toEntity()]),
    ).called(1);
  });

  test('login discovers FlatContextService via Get.find when not passed in constructor', () async {
    Get.put<FlatContextService>(mockFlatContextService);
    final repoWithoutInjectedFcs = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );

    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenAnswer((_) async => responseModel);
    when(
      () => mockLocalDataSource.saveTokens(
        accessToken: responseModel.token,
        refreshToken: responseModel.token,
      ),
    ).thenAnswer((_) async {});
    when(() => mockFlatContextService.initializeFlats(any())).thenReturn(null);

    final result = await repoWithoutInjectedFcs.login(email: email, password: password);

    expect(result.isRight(), isTrue);
    verify(() => mockFlatContextService.initializeFlats([flatModel.toEntity()])).called(1);
  });

  test('login succeeds without FlatContextService when none is registered', () async {
    final repoWithoutFcs = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );

    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenAnswer((_) async => responseModel);
    when(
      () => mockLocalDataSource.saveTokens(
        accessToken: responseModel.token,
        refreshToken: responseModel.token,
      ),
    ).thenAnswer((_) async {});

    final result = await repoWithoutFcs.login(email: email, password: password);

    expect(result.isRight(), isTrue);
  });

  test('login returns Left(Failure) when DioException contains Failure in error field', () async {
    const customFailure = AuthFailure('Invalid credentials provided');
    final dioException = DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      error: customFailure,
    );

    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenThrow(dioException);

    final result = await repository.login(email: email, password: password);

    expect(result, equals(const Left<Failure, UserEntity>(customFailure)));
    verifyZeroInteractions(mockLocalDataSource);
    verifyZeroInteractions(mockFlatContextService);
  });

  test('login returns Left(ServerFailure) when DioException without Failure error is thrown', () async {
    final dioException = DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      message: 'Connection timed out',
    );

    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenThrow(dioException);

    final result = await repository.login(email: email, password: password);

    expect(result, equals(const Left<Failure, UserEntity>(ServerFailure('Connection timed out'))));
    verifyZeroInteractions(mockLocalDataSource);
  });

  test('login returns Left(CacheFailure) when CacheException is thrown while saving tokens', () async {
    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenAnswer((_) async => responseModel);
    when(
      () => mockLocalDataSource.saveTokens(
        accessToken: responseModel.token,
        refreshToken: responseModel.token,
      ),
    ).thenThrow(const CacheException('Failed to save tokens to secure storage'));

    final result = await repository.login(email: email, password: password);

    expect(
      result,
      equals(const Left<Failure, UserEntity>(CacheFailure('Failed to save tokens to secure storage'))),
    );
    verify(() => mockRemoteDataSource.login(email: email, password: password)).called(1);
    verify(
      () => mockLocalDataSource.saveTokens(
        accessToken: responseModel.token,
        refreshToken: responseModel.token,
      ),
    ).called(1);
  });

  test('login returns Left(ServerFailure) when an unexpected generic exception occurs', () async {
    when(() => mockRemoteDataSource.login(email: email, password: password))
        .thenThrow(Exception('Unexpected crash'));

    final result = await repository.login(email: email, password: password);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ServerFailure>()),
      (_) => fail('Should be failure'),
    );
  });
}
