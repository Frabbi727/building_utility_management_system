import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/bills_controller.dart';
import '../widgets/bill_card.dart';

class BillsScreen extends GetView<BillsController> {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filters = [
      {'key': 'all', 'label': context.l10n.all},
      {'key': 'unpaid', 'label': context.l10n.statusUnpaid},
      {'key': 'partially_paid', 'label': context.l10n.statusPartiallyPaid},
      {'key': 'paid', 'label': context.l10n.statusPaid},
    ];

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 12.h),
          SizedBox(
            height: 40.h,
            child: Obx(
              () => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: filters.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = controller.selectedStatus.value == filter['key'];

                  return ChoiceChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    onSelected: (_) => controller.filterByStatus(filter['key']!),
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final state = controller.state.value;

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
                          onPressed: controller.refreshBills,
                          icon: const Icon(Icons.refresh),
                          label: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final bills = controller.bills;
              if (bills.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56.sp,
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          context.l10n.noBillsFound,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshBills,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    return BillCard(bill: bills[index]);
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
