import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.loginTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0.0, constraints.maxHeight - 32.h),
                ),
                child: Obx(() {
                  final currentState = controller.state.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.loginTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16.h),
                      if (currentState is ErrorState) ...[
                        Text(
                          currentState.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      AppTextField(
                        key: const Key('email_field'),
                        controller: controller.emailController,
                        labelText: context.l10n.emailLabel,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12.h),
                      AppTextField(
                        key: const Key('password_field'),
                        controller: controller.passwordController,
                        obscureText: true,
                        labelText: context.l10n.passwordLabel,
                      ),
                      SizedBox(height: 24.h),
                      AppButton(
                        key: const Key('login_button'),
                        text: context.l10n.loginButton,
                        isLoading: currentState is LoadingState,
                        onPressed: () => controller.login(
                          controller.emailController.text,
                          controller.passwordController.text,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
