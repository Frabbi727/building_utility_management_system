import 'package:get/get.dart';
import '../../../bills/presentation/bindings/bills_binding.dart';
import '../../../dashboard/presentation/bindings/dashboard_binding.dart';
import '../../../maintenance/presentation/bindings/maintenance_binding.dart';
import '../../../notifications/presentation/bindings/notification_binding.dart';
import '../../../payments/presentation/bindings/payments_binding.dart';
import '../controllers/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    DashboardBinding().dependencies();
    BillsBinding().dependencies();
    PaymentsBinding().dependencies();
    MaintenanceBinding().dependencies();
    NotificationBinding().dependencies();
  }
}

