import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/latest_bill_card.dart';
import '../widgets/notices_banner_widget.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_activity_list.dart';
import '../../../notices/presentation/widgets/notice_detail_bottom_sheet.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        final currentState = controller.state.value;

        if (currentState is LoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (currentState is ErrorState) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    currentState.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: controller.refreshDashboard,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (currentState is SuccessState<DashboardDataEntity>) {
          final data = currentState.data;

          return RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceHeroCard(balances: data.balances),
                  SizedBox(height: 16.h),
                  const QuickActionsRow(),
                  if (data.latestBill != null) ...[
                    SizedBox(height: 16.h),
                    LatestBillCard(bill: data.latestBill!),
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
                    RecentActivityList(activities: data.recentActivity),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
