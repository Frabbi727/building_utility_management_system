import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/recent_activity_entity.dart';

class RecentActivityList extends StatelessWidget {
  final List<RecentActivityEntity> activities;
  final ValueChanged<RecentActivityEntity>? onActivityTap;

  const RecentActivityList({
    super.key,
    required this.activities,
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              context.l10n.recentActivity,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...activities.map(
          (activity) => _ActivityTile(
            activity: activity,
            onTap: onActivityTap != null ? () => onActivityTap!(activity) : null,
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivityEntity activity;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isPayment = activity.type.toLowerCase() == 'payment';
    final isMaintenance = activity.type.toLowerCase() == 'maintenance' ||
        activity.type.toLowerCase() == 'ticket';

    final icon = isPayment
        ? Icons.payment
        : (isMaintenance ? Icons.build_outlined : Icons.receipt_long);

    final color = isPayment
        ? Colors.teal
        : (isMaintenance ? Colors.deepOrange : Colors.indigo);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    activity.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (activity.amount.isNotEmpty && activity.amount != '0.00')
                  Text(
                    '৳ ${activity.amount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _statusColor(activity.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    activity.status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor(activity.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
      case 'resolved':
      case 'completed':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'rejected':
      case 'failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
