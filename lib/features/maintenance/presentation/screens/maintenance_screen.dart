import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../controllers/maintenance_controller.dart';
import '../widgets/create_ticket_bottom_sheet.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/maintenance_filter_bar.dart';

class MaintenanceScreen extends GetView<MaintenanceController> {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => CreateTicketBottomSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createTicket),
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          const MaintenanceFilterBar(),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final currentState = controller.state.value;

              if (currentState is LoadingState && controller.requests.isEmpty) {
                return const CardListSkeleton(itemCount: 4, cardHeight: 120);
              }

              if (currentState is ErrorState && controller.requests.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to load maintenance requests',
                  message: currentState.message,
                  actionLabel: context.l10n.retry,
                  onAction: controller.refreshRequests,
                  iconColor: Theme.of(context).colorScheme.error,
                );
              }

              final requests = controller.requests;
              if (requests.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshRequests,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400.h,
                      child: EmptyStateWidget(
                        icon: Icons.build_circle_outlined,
                        title: context.l10n.noMaintenanceRequests,
                        message: 'No maintenance requests found matching your filter criteria.',
                        actionLabel: context.l10n.createTicket,
                        onAction: () => CreateTicketBottomSheet.show(context),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshRequests,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 88.h),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return MaintenanceCard(request: requests[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
