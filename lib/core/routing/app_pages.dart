import 'package:get/get.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/navigation/presentation/bindings/navigation_binding.dart';
import '../../features/navigation/presentation/screens/navigation_screen.dart';
import 'auth_middleware.dart';
import 'route_names.dart';

abstract final class AppPages {
  static const initial = AppRoutes.login;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const NavigationScreen(),
      binding: NavigationBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
