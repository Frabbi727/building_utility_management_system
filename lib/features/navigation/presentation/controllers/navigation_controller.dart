import 'package:get/get.dart';
import '../../../bills/presentation/controllers/bills_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../maintenance/presentation/controllers/maintenance_controller.dart';
import '../../../payments/presentation/controllers/payments_controller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    if (index >= 0 && index < 4) {
      currentIndex.value = index;
      _notifyTabActivated(index);
    }
  }

  void _notifyTabActivated(int index) {
    switch (index) {
      case 0:
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().onTabVisible();
        }
        break;
      case 1:
        if (Get.isRegistered<BillsController>()) {
          Get.find<BillsController>().onTabVisible();
        }
        break;
      case 2:
        if (Get.isRegistered<PaymentsController>()) {
          Get.find<PaymentsController>().onTabVisible();
        }
        break;
      case 3:
        if (Get.isRegistered<MaintenanceController>()) {
          Get.find<MaintenanceController>().onTabVisible();
        }
        break;
    }
  }
}
