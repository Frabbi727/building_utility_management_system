import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../routing/route_names.dart';
import '../../features/navigation/presentation/controllers/navigation_controller.dart';

abstract final class NotificationRouter {
  /// Routes a notification payload or RemoteMessage to the appropriate screen or tab.
  static void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    handlePayload(message.data);
  }

  /// Routes given a data map containing screen and reference parameters.
  static void handlePayload(Map<String, dynamic> data) {
    debugPrint('NotificationRouter: Handling payload: $data');

    final screen = (data['screen'] as String?)?.toLowerCase() ?? '';
    final type = (data['type'] as String?)?.toUpperCase() ?? '';

    // 1. Check direct screen targets
    switch (screen) {
      case 'bills':
        _switchToTab(1);
        return;
      case 'payments':
        _switchToTab(2);
        return;
      case 'maintenance':
        _switchToTab(3);
        return;
      case 'notifications':
        Get.toNamed<dynamic>(AppRoutes.notifications);
        return;
    }

    // 2. Fallback to notification type matching
    if (type.contains('BILL')) {
      _switchToTab(1);
    } else if (type.contains('PAYMENT')) {
      _switchToTab(2);
    } else if (type.contains('MAINTENANCE') || type.contains('TICKET')) {
      _switchToTab(3);
    } else {
      // Default: open in-app Notification Center
      Get.toNamed<dynamic>(AppRoutes.notifications);
    }
  }

  static void _switchToTab(int tabIndex) {
    if (Get.isRegistered<NavigationController>()) {
      final nav = Get.find<NavigationController>();
      nav.changeTab(tabIndex);
      if (Get.key.currentState != null && Get.currentRoute != AppRoutes.home) {
        Get.until((route) => Get.currentRoute == AppRoutes.home);
      }
    } else {
      Get.offAllNamed<dynamic>(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<NavigationController>()) {
          Get.find<NavigationController>().changeTab(tabIndex);
        }
      });
    }
  }
}
