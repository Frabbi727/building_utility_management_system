import 'dart:async';
import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:building_utility_management_system/features/auth/domain/usecases/login_usecase.dart';
import 'package:building_utility_management_system/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLoginUseCase mockLoginUseCase;
  late AuthController controller;

  setUp(() {
    Get.testMode = true;
    mockLoginUseCase = MockLoginUseCase();
    controller = AuthController(loginUseCase: mockLoginUseCase);
  });

  tearDown(() {
    Get.reset();
  });

  test('initial state is IdleState', () {
    expect(controller.state.value, equals(const IdleState()));
  });

  test('login sets LoadingState while login usecase is executing', () async {
    final completer = Completer<Either<Failure, UserEntity>>();
    when(() => mockLoginUseCase(email: 'test@example.com', password: 'password'))
        .thenAnswer((_) => completer.future);

    final loginFuture = controller.login('test@example.com', 'password');

    expect(controller.state.value, equals(const LoadingState()));

    completer.complete(
      const Right<Failure, UserEntity>(
        UserEntity(id: '1', name: 'User', email: 'test@example.com'),
      ),
    );
    await loginFuture;
  });

  test('login sets ErrorState when LoginUseCase returns Left(ServerFailure)', () async {
    when(() => mockLoginUseCase(email: 'test@example.com', password: 'password'))
        .thenAnswer((_) async => const Left<Failure, UserEntity>(ServerFailure('Invalid credentials')));

    await controller.login('test@example.com', 'password');

    expect(controller.state.value, equals(const ErrorState('Invalid credentials')));
  });

  test('login sets SuccessState when LoginUseCase returns Right(UserEntity)', () async {
    const user = UserEntity(id: '1', name: 'Test User', email: 'test@example.com');
    when(() => mockLoginUseCase(email: 'test@example.com', password: 'password'))
        .thenAnswer((_) async => const Right<Failure, UserEntity>(user));

    await controller.login('test@example.com', 'password');

    expect(controller.state.value, equals(const SuccessState<UserEntity>(user)));
  });
}
