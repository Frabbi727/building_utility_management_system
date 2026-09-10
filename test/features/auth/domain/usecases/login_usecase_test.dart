import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:building_utility_management_system/features/auth/domain/repositories/auth_repository.dart';
import 'package:building_utility_management_system/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(repository: mockRepository);
  });

  const testEmail = 'user@example.com';
  const testPassword = 'password123';
  const testUser = UserEntity(
    id: 'user-1',
    name: 'Test User',
    email: testEmail,
  );

  test('UserEntity equality works based on props', () {
    const user1 = UserEntity(id: '1', name: 'A', email: 'a@example.com');
    const user2 = UserEntity(id: '1', name: 'A', email: 'a@example.com');
    const user3 = UserEntity(id: '2', name: 'B', email: 'b@example.com');

    expect(user1, equals(user2));
    expect(user1 == user3, isFalse);
  });

  test('should return Right(UserEntity) when repository login succeeds', () async {
    when(() => mockRepository.login(email: testEmail, password: testPassword))
        .thenAnswer((_) async => const Right<Failure, UserEntity>(testUser));

    final result = await useCase(email: testEmail, password: testPassword);

    expect(result, equals(const Right<Failure, UserEntity>(testUser)));
    verify(() => mockRepository.login(email: testEmail, password: testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Left(Failure) when repository login fails', () async {
    const failure = AuthFailure('Invalid credentials');
    when(() => mockRepository.login(email: testEmail, password: testPassword))
        .thenAnswer((_) async => const Left<Failure, UserEntity>(failure));

    final result = await useCase(email: testEmail, password: testPassword);

    expect(result, equals(const Left<Failure, UserEntity>(failure)));
    verify(() => mockRepository.login(email: testEmail, password: testPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
