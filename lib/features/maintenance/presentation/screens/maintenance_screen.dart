import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/maintenance_controller.dart';
import '../widgets/create_ticket_bottom_sheet.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/maintenance_filter_bar.dart';

class MaintenanceScreen extends GetView<MaintenanceController> {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'maintenance_create_fab',
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
                          onPressed: controller.refreshRequests,
                          icon: const Icon(Icons.refresh),
                          label: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final requests = controller.requests;
              if (requests.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 56.sp,
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          context.l10n.noMaintenanceRequests,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        OutlinedButton.icon(
                          onPressed: () => CreateTicketBottomSheet.show(context),
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.createTicket),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshRequests,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
