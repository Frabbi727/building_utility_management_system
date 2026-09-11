import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../../bills/presentation/screens/bills_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../maintenance/presentation/screens/maintenance_screen.dart';
import '../../../payments/presentation/screens/payments_screen.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/flat_selector_bottom_sheet.dart';

class NavigationScreen extends GetView<NavigationController> {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flatService = Get.isRegistered<FlatContextService>()
        ? Get.find<FlatContextService>()
        : null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16.w,
        title: flatService != null
            ? Obx(() {
                final selected = flatService.selectedFlat.value;
                final label = selected != null
                    ? selected.displayName
                    : context.l10n.selectFlat;

                return InkWell(
                  onTap: () => FlatSelectorBottomSheet.show(context),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200.w),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 20.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                );
              })
            : Text(context.l10n.homeTitle),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const DashboardScreen(),
            const BillsScreen(),
            const PaymentsScreen(),
            const MaintenanceScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: context.l10n.navBills,
            ),
            NavigationDestination(
              icon: const Icon(Icons.payment_outlined),
              selectedIcon: const Icon(Icons.payment),
              label: context.l10n.navPayments,
            ),
            NavigationDestination(
              icon: const Icon(Icons.build_outlined),
              selectedIcon: const Icon(Icons.build),
              label: context.l10n.navMaintenance,
            ),
          ],
        ),
      ),
    );
  }
}
