import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/routing/route_names.dart';
import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:building_utility_management_system/features/auth/domain/usecases/login_usecase.dart';
import 'package:building_utility_management_system/features/auth/presentation/controllers/auth_controller.dart';
import 'package:building_utility_management_system/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late AuthController controller;

  setUp(() {
    Get.reset();
    mockLoginUseCase = MockLoginUseCase();
    controller = AuthController(loginUseCase: mockLoginUseCase);
    Get.put<AuthController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.login,
        getPages: [
          GetPage<dynamic>(name: AppRoutes.login, page: () => const LoginScreen()),
          GetPage<dynamic>(name: AppRoutes.home, page: () => const Scaffold(body: Text('Home'))),
        ],
      ),
    );
  }

  testWidgets('renders email field, password field, and login button', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
    expect(find.text('Sign In'), findsNWidgets(2));
  });

  testWidgets('displays error text when controller state is ErrorState', (tester) async {
    controller.state.value = const ErrorState('Authentication failed');

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Authentication failed'), findsOneWidget);
  });

  testWidgets('displays CircularProgressIndicator when state is LoadingState', (tester) async {
    controller.state.value = const LoadingState();

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Login'), findsNothing);
  });

  testWidgets('pressing login button executes controller.login', (tester) async {
    when(() => mockLoginUseCase(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => const Right<Failure, UserEntity>(
              UserEntity(id: '1', name: 'User', email: 'test@example.com'),
            ));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email_field')), 'user@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    verify(() => mockLoginUseCase(email: 'user@example.com', password: 'password123')).called(1);
    expect(find.text('Home'), findsOneWidget);
  });
}
