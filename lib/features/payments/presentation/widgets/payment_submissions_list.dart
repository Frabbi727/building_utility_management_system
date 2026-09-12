import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/payment_submission_entity.dart';
import '../controllers/payments_controller.dart';
import 'submit_payment_bottom_sheet.dart';

class PaymentSubmissionsList extends GetView<PaymentsController> {
  const PaymentSubmissionsList({super.key});

  Color _getStatusColor(PaymentSubmissionStatus status) {
    switch (status) {
      case PaymentSubmissionStatus.pending:
        return Colors.amber.shade700;
      case PaymentSubmissionStatus.approved:
        return Colors.green.shade700;
      case PaymentSubmissionStatus.rejected:
        return Colors.red.shade700;
    }
  }

  String _getStatusLabel(BuildContext context, PaymentSubmissionStatus status) {
    switch (status) {
      case PaymentSubmissionStatus.pending:
        return context.l10n.statusPending;
      case PaymentSubmissionStatus.approved:
        return context.l10n.statusApproved;
      case PaymentSubmissionStatus.rejected:
        return context.l10n.statusRejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final state = controller.submissionsState.value;

      if (state is LoadingState) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is ErrorState) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: theme.colorScheme.error),
                SizedBox(height: 12.h),
                Text(state.message, textAlign: TextAlign.center),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: controller.refreshAll,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        );
      }

      final submissions = controller.submissions;
      if (submissions.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_outlined,
                    size: 56.sp, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                SizedBox(height: 12.h),
                Text(
                  context.l10n.noSubmissionsFound,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 16.h),
                OutlinedButton.icon(
                  onPressed: () => SubmitPaymentBottomSheet.show(context),
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.submitPaymentProof),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 88.h),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final item = submissions[index];
            final statusColor = _getStatusColor(item.status);

            return Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৳ ${item.amount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _getStatusLabel(context, item.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${item.paymentMethod.toUpperCase()} • ${item.referenceNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.paymentDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    if (item.rejectionReason != null &&
                        item.rejectionReason!.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.rejectionReason,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.rejectionReason!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
