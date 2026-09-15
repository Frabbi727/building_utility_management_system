import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/notification_entity.dart';
import '../controllers/notification_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController controller = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUnreadCount();
      controller.fetchNotifications(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            final unread = controller.unreadCount.value;
            if (unread == 0) return const SizedBox.shrink();

            return TextButton(
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: context.l10n.markAllAsReadTitle,
                  message: context.l10n.markAllAsReadConfirm,
                  confirmText: context.l10n.confirm,
                  cancelText: context.l10n.cancel,
                );
                if (confirmed == true) {
                  await controller.markAllAsRead();
                }
              },
              child: Text(context.l10n.markAllRead),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          _buildFilterChips(context),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final state = controller.state.value;

              if (state is LoadingState && controller.notifications.isEmpty) {
                return const CardListSkeleton(itemCount: 5, cardHeight: 80);
              }

              if (state is ErrorState && controller.notifications.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to load notifications',
                  message: state.message,
                  actionLabel: 'Retry',
                  onAction: () => controller.fetchNotifications(isRefresh: true),
                  iconColor: Theme.of(context).colorScheme.error,
                );
              }

              final list = controller.notifications;
              if (list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchUnreadCount();
                    await controller.fetchNotifications(isRefresh: true);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400.h,
                      child: const EmptyStateWidget(
                        icon: Icons.notifications_none,
                        title: 'No notifications yet',
                        message: 'You have caught up with all building notices and account updates.',
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchUnreadCount();
                  await controller.fetchNotifications(isRefresh: true);
                },
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildNotificationCard(context, item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    const filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'unread', 'label': 'Unread'},
      {'key': 'read', 'label': 'Read'},
    ];

    return SizedBox(
      height: 38.h,
      child: Obx(() {
        final active = controller.selectedFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: filters.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final f = filters[index];
            final isSelected = active == f['key'];

            return ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (_) => controller.setFilter(f['key']!),
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationEntity item) {
    final theme = Theme.of(context);
    final iconData = _getIconForType(item.type);
    final iconColor = _getColorForType(item.type, theme);
    final timeStr = _formatTimestamp(item.createdAt);

    return InkWell(
      onTap: () => controller.onNotificationTap(item),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: item.isRead
              ? theme.cardColor
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: item.isRead
                ? theme.dividerColor.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            width: item.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              SizedBox(width: 8.w),
              Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.only(top: 6.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'BILL_GENERATED':
        return Icons.receipt_long;
      case 'PAYMENT_APPROVED':
        return Icons.check_circle_outline;
      case 'PAYMENT_REJECTED':
        return Icons.highlight_off;
      case 'MAINTENANCE_UPDATED':
        return Icons.build_circle_outlined;
      case 'NOTICE_PUBLISHED':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(String type, ThemeData theme) {
    switch (type.toUpperCase()) {
      case 'BILL_GENERATED':
        return Colors.indigo;
      case 'PAYMENT_APPROVED':
        return Colors.green;
      case 'PAYMENT_REJECTED':
        return Colors.red;
      case 'MAINTENANCE_UPDATED':
        return Colors.orange;
      case 'NOTICE_PUBLISHED':
        return Colors.teal;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dt);
    }
  }
}
