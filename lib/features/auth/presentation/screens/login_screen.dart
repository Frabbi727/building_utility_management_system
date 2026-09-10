import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: 'user@example.com');
    final passwordController = TextEditingController(text: 'password123');

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.loginTitle)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Obx(() {
          final currentState = controller.state.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login Screen',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16.h),
              if (currentState is ErrorState) ...[
                Text(
                  currentState.message,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
                SizedBox(height: 12.h),
              ],
              TextField(
                key: const Key('email_field'),
                controller: emailController,
                decoration: InputDecoration(labelText: context.l10n.emailLabel),
              ),
              SizedBox(height: 12.h),
              TextField(
                key: const Key('password_field'),
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: context.l10n.passwordLabel),
              ),
              SizedBox(height: 24.h),
              if (currentState is LoadingState)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: () => controller.login(
                    emailController.text,
                    passwordController.text,
                  ),
                  child: Text(context.l10n.loginButton),
                ),
            ],
          );
        }),
      ),
    );
  }
}
