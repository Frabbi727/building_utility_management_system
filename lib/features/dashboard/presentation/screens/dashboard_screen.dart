import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/latest_bill_card.dart';
import '../widgets/notices_banner_widget.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_activity_list.dart';
import '../../../navigation/presentation/controllers/navigation_controller.dart';
import '../../../notices/presentation/widgets/notice_detail_bottom_sheet.dart';
import '../../../payments/presentation/widgets/submit_payment_bottom_sheet.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final currentState = controller.state.value;

        if (currentState is LoadingState) {
          return const DashboardSkeleton();
        }

        if (currentState is ErrorState) {
          return EmptyStateWidget(
            icon: Icons.cloud_off_outlined,
            title: 'Unable to load dashboard',
            message: currentState.message,
            actionLabel: context.l10n.retry,
            onAction: controller.refreshDashboard,
            iconColor: Theme.of(context).colorScheme.error,
          );
        }

        if (currentState is SuccessState<DashboardDataEntity>) {
          final data = currentState.data;

          return RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceHeroCard(
                    balances: data.balances,
                    onPayNow: () => SubmitPaymentBottomSheet.show(
                      context,
                      initialAmount: data.balances.totalDue.replaceAll(',', ''),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const QuickActionsRow(),
                  if (data.latestBill != null) ...[
                    SizedBox(height: 16.h),
                    LatestBillCard(
                      bill: data.latestBill!,
                      onViewBill: () {
                        if (Get.isRegistered<NavigationController>()) {
                          Get.find<NavigationController>().changeTab(1);
                        }
                      },
                    ),
                  ],
                  if (data.activeNotices.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    NoticesBannerWidget(
                      notices: data.activeNotices,
                      onNoticeTap: (notice) =>
                          NoticeDetailBottomSheet.show(context, notice),
                    ),
                  ],
                  if (data.recentActivity.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    RecentActivityList(
                      activities: data.recentActivity,
                      onActivityTap: (activity) {
                        if (Get.isRegistered<NavigationController>()) {
                          final nav = Get.find<NavigationController>();
                          final type = activity.type.toLowerCase();
                          if (type == 'payment') {
                            nav.changeTab(2);
                          } else if (type == 'maintenance' || type == 'ticket') {
                            nav.changeTab(3);
                          } else {
                            nav.changeTab(1);
                          }
                        }
                      },
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }

        return const DashboardSkeleton();
      }),
    );
  }
}
