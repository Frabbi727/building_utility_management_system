import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../controllers/payments_controller.dart';

class VerifiedPaymentsList extends GetView<PaymentsController> {
  const VerifiedPaymentsList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final state = controller.paymentsState.value;

      if (state is LoadingState && controller.payments.isEmpty) {
        return const CardListSkeleton(itemCount: 4, cardHeight: 120);
      }

      if (state is ErrorState && controller.payments.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Unable to load payments',
          message: state.message,
          actionLabel: context.l10n.retry,
          onAction: controller.refreshAll,
          iconColor: Theme.of(context).colorScheme.error,
        );
      }

      final payments = controller.payments;
      if (payments.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 400.h,
              child: EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: context.l10n.noPaymentsFound,
                message: 'No verified payments recorded for this flat yet.',
                actionLabel: context.l10n.retry,
                onAction: controller.refreshAll,
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 88.h),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final item = payments[index];

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
                          item.receiptNo,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '৳ ${item.amount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.method.toUpperCase()} • ${item.reference}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          item.receivedOn,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => controller.openReceiptUrl(item.receiptUrl),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: Text(context.l10n.downloadReceipt),
                      ),
                    ),
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
