import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../controllers/bills_controller.dart';
import '../widgets/bill_card.dart';

class BillsScreen extends GetView<BillsController> {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Obx(() {
              final activeStatus = controller.selectedStatus.value;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: filters.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = activeStatus == filter['key'];

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
              );
            }),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              final state = controller.state.value;

              if (state is LoadingState && controller.bills.isEmpty) {
                return const CardListSkeleton(itemCount: 4, cardHeight: 110);
              }

              if (state is ErrorState && controller.bills.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to load bills',
                  message: state.message,
                  actionLabel: context.l10n.retry,
                  onAction: controller.refreshBills,
                  iconColor: Theme.of(context).colorScheme.error,
                );
              }

              final bills = controller.bills;
              if (bills.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshBills,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400.h,
                      child: EmptyStateWidget(
                        icon: Icons.receipt_long_outlined,
                        title: context.l10n.noBillsFound,
                        message: 'No bills match the selected status filter.',
                        actionLabel: context.l10n.retry,
                        onAction: controller.refreshBills,
                      ),
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
