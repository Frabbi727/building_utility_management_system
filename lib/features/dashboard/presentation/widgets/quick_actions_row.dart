import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../navigation/presentation/controllers/navigation_controller.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onPayBill;
  final VoidCallback? onViewBills;
  final VoidCallback? onMaintenance;

  const QuickActionsRow({
    super.key,
    this.onPayBill,
    this.onViewBills,
    this.onMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : null;

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.payment,
            label: context.l10n.navPayments,
            color: Colors.teal,
            onTap: () {
              if (onPayBill != null) {
                onPayBill!();
              } else {
                navController?.changeTab(2);
              }
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ActionCard(
            icon: Icons.receipt_long,
            label: context.l10n.navBills,
            color: Colors.indigo,
            onTap: () {
              if (onViewBills != null) {
                onViewBills!();
              } else {
                navController?.changeTab(1);
              }
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ActionCard(
            icon: Icons.build_outlined,
            label: context.l10n.navMaintenance,
            color: Colors.deepOrange,
            onTap: () {
              if (onMaintenance != null) {
                onMaintenance!();
              } else {
                navController?.changeTab(3);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 22.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
