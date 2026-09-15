import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../payments/presentation/widgets/submit_payment_bottom_sheet.dart';
import '../../domain/entities/bill_entity.dart';
import '../controllers/bills_controller.dart';
import '../screens/bill_details_screen.dart';
import 'bill_status_chip.dart';

class BillCard extends StatelessWidget {
  final BillEntity bill;

  const BillCard({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              builder: (_) => BillDetailsScreen(bill: bill),
            ),
          );
          if (Get.isRegistered<BillsController>()) {
            Get.find<BillsController>().refreshBills();
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.billingMonth,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        bill.billNo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  BillStatusChip(status: bill.status),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.dueDate,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        bill.dueDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳ ${bill.totalAmount}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: bill.isPaid ? Colors.green.shade700 : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (!bill.isPaid) ...[
                SizedBox(height: 12.h),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      SubmitPaymentBottomSheet.show(
                        context,
                        initialAmount: bill.totalAmount,
                        initialReference: bill.billNo,
                      );
                    },
                    icon: const Icon(Icons.payment, size: 16),
                    label: Text(context.l10n.payNow),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
