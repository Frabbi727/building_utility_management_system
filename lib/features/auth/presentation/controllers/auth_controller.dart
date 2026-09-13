import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  AuthController({required this.loginUseCase});

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  final Rx<ViewState> state = Rx<ViewState>(const IdleState());

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login(String email, String password) async {
    if (state.value is LoadingState) return;
    state.value = const LoadingState();
    final result = await loginUseCase(email: email, password: password);
    if (isClosed) return;
    result.fold(
      (failure) => state.value = ErrorState(failure.message),
      (user) {
        state.value = SuccessState<UserEntity>(user);
        if (Get.isRegistered<FirebaseNotificationService>()) {
          Get.find<FirebaseNotificationService>().syncDeviceRegistration();
        }
        Get.offAllNamed<dynamic>(AppRoutes.home);
      },
    );
  }
}
