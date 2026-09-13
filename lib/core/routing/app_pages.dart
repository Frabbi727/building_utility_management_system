import 'package:get/get.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/navigation/presentation/bindings/navigation_binding.dart';
import '../../features/navigation/presentation/screens/navigation_screen.dart';
import '../../features/notifications/presentation/bindings/notification_binding.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/bindings/profile_binding.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
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
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
