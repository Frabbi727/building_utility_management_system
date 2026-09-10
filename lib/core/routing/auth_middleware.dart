import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../storage/secure_storage_service.dart';
import 'route_names.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == AppRoutes.login) return null;
    final storageService = Get.find<SecureStorageService>();
    if (!storageService.hasToken) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
