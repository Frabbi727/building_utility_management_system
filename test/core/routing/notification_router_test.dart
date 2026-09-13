import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:building_utility_management_system/core/routing/notification_router.dart';
import 'package:building_utility_management_system/features/navigation/presentation/controllers/navigation_controller.dart';

void main() {
  late NavigationController nav;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    nav = NavigationController();
    Get.put<NavigationController>(nav);
  });

  tearDown(() {
    Get.reset();
  });

  group('NotificationRouter', () {
    test('routes screen: bills to tab 1', () {
      NotificationRouter.handlePayload({
        'screen': 'bills',
        'reference_id': '10',
      });

      expect(nav.currentIndex.value, 1);
    });

    test('routes screen: payments to tab 2', () {
      NotificationRouter.handlePayload({
        'screen': 'payments',
        'reference_id': '20',
      });

      expect(nav.currentIndex.value, 2);
    });

    test('routes screen: maintenance to tab 3', () {
      NotificationRouter.handlePayload({
        'screen': 'maintenance',
        'reference_id': '30',
      });

      expect(nav.currentIndex.value, 3);
    });

    test('routes type: BILL_GENERATED to tab 1', () {
      NotificationRouter.handlePayload({
        'type': 'BILL_GENERATED',
      });

      expect(nav.currentIndex.value, 1);
    });

    test('routes type: PAYMENT_APPROVED to tab 2', () {
      NotificationRouter.handlePayload({
        'type': 'PAYMENT_APPROVED',
      });

      expect(nav.currentIndex.value, 2);
    });

    test('routes type: MAINTENANCE_UPDATED to tab 3', () {
      NotificationRouter.handlePayload({
        'type': 'MAINTENANCE_UPDATED',
      });

      expect(nav.currentIndex.value, 3);
    });
  });
}
