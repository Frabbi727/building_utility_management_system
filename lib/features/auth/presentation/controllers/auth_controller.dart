import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/routing/route_names.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  AuthController({required this.loginUseCase});

  final Rx<ViewState> state = Rx<ViewState>(const IdleState());

  Future<void> login(String email, String password) async {
    state.value = const LoadingState();
    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (failure) => state.value = ErrorState(failure.message),
      (user) {
        state.value = SuccessState<UserEntity>(user);
        Get.offAllNamed<dynamic>(AppRoutes.home);
      },
    );
  }
}
