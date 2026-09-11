import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/maintenance_controller.dart';

class MaintenanceFilterBar extends GetView<MaintenanceController> {
  const MaintenanceFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': context.l10n.all},
      {'key': 'open', 'label': context.l10n.statusOpen},
      {'key': 'in_progress', 'label': context.l10n.statusInProgress},
      {'key': 'resolved', 'label': context.l10n.statusResolved},
      {'key': 'closed', 'label': context.l10n.statusClosed},
    ];

    return SizedBox(
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
    );
  }
}
