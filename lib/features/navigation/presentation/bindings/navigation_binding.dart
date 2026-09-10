import 'package:get/get.dart';
import '../../../dashboard/presentation/bindings/dashboard_binding.dart';
import '../controllers/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    DashboardBinding().dependencies();
  }
}
