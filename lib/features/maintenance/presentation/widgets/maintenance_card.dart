import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../domain/entities/maintenance_request_entity.dart';
import '../controllers/maintenance_controller.dart';
import '../screens/maintenance_details_screen.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceRequestEntity request;

  const MaintenanceCard({
    super.key,
    required this.request,
  });

  IconData _getCategoryIcon(MaintenanceCategory category) {
    switch (category) {
      case MaintenanceCategory.plumbing:
        return Icons.plumbing;
      case MaintenanceCategory.electrical:
        return Icons.electrical_services;
      case MaintenanceCategory.elevator:
        return Icons.elevator;
      case MaintenanceCategory.cleaning:
        return Icons.cleaning_services;
      case MaintenanceCategory.security:
        return Icons.security;
      case MaintenanceCategory.other:
        return Icons.build_circle_outlined;
    }
  }

  Color _getStatusColor(MaintenanceStatus status, ColorScheme scheme) {
    switch (status) {
      case MaintenanceStatus.open:
        return Colors.amber.shade700;
      case MaintenanceStatus.inProgress:
        return Colors.blue.shade700;
      case MaintenanceStatus.resolved:
        return Colors.green.shade700;
      case MaintenanceStatus.closed:
        return scheme.outline;
    }
  }

  String _getStatusLabel(BuildContext context, MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.open:
        return context.l10n.statusOpen;
      case MaintenanceStatus.inProgress:
        return context.l10n.statusInProgress;
      case MaintenanceStatus.resolved:
        return context.l10n.statusResolved;
      case MaintenanceStatus.closed:
        return context.l10n.statusClosed;
    }
  }

  Color _getPriorityColor(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return Colors.grey.shade600;
      case MaintenancePriority.medium:
        return Colors.blue.shade600;
      case MaintenancePriority.high:
        return Colors.orange.shade700;
      case MaintenancePriority.emergency:
        return Colors.red.shade700;
    }
  }

  String _getPriorityLabel(BuildContext context, MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return context.l10n.priorityLow;
      case MaintenancePriority.medium:
        return context.l10n.priorityMedium;
      case MaintenancePriority.high:
        return context.l10n.priorityHigh;
      case MaintenancePriority.emergency:
        return context.l10n.priorityEmergency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(request.status, theme.colorScheme);
    final priorityColor = _getPriorityColor(request.priority);

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MaintenanceDetailsScreen(request: request),
            ),
          );
          if (Get.isRegistered<MaintenanceController>()) {
            Get.find<MaintenanceController>().refreshRequests();
          }
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().refreshDashboard();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(request.category),
                      color: theme.colorScheme.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          request.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _getPriorityLabel(context, request.priority),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _getStatusLabel(context, request.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
