import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/resident_balances_entity.dart';

class BalanceHeroCard extends StatelessWidget {
  final ResidentBalancesEntity balances;
  final VoidCallback? onPayNow;

  const BalanceHeroCard({
    super.key,
    required this.balances,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDue = balances.hasOutstandingDue;
    final advanceAmount = double.tryParse(balances.advanceHeld.replaceAll(',', '')) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
            theme.colorScheme.secondary.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.totalDue,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: hasDue
                      ? Colors.amber.withValues(alpha: 0.25)
                      : Colors.greenAccent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasDue
                        ? Colors.amber.withValues(alpha: 0.6)
                        : Colors.greenAccent.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasDue ? Icons.error_outline : Icons.check_circle_outline,
                      size: 14.sp,
                      color: hasDue ? Colors.amberAccent : Colors.greenAccent,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      hasDue ? context.l10n.totalDue : context.l10n.allClear,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '৳ ${balances.totalDue}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          if (advanceAmount > 0) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${context.l10n.advanceHeld}: ৳ ${balances.advanceHeld}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SubStat(
                  label: context.l10n.currentMonthCharges,
                  value: '৳ ${balances.currentMonthCharges}',
                ),
                Container(
                  width: 1.w,
                  height: 28.h,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _SubStat(
                  label: context.l10n.arrears,
                  value: '৳ ${balances.arrears}',
                ),
              ],
            ),
          ),
          if (hasDue) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPayNow,
                icon: const Icon(Icons.payment),
                label: Text(
                  context.l10n.payNow,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubStat extends StatelessWidget {
  final String label;
  final String value;

  const _SubStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
