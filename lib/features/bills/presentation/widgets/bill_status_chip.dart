import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/bill_entity.dart';

class BillStatusChip extends StatelessWidget {
  final BillStatus status;

  const BillStatusChip({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case BillStatus.paid:
        return Colors.green.shade700;
      case BillStatus.partiallyPaid:
        return Colors.amber.shade700;
      case BillStatus.unpaid:
        return Colors.red.shade700;
    }
  }

  String _getLabel(BuildContext context) {
    switch (status) {
      case BillStatus.paid:
        return context.l10n.statusPaid;
      case BillStatus.partiallyPaid:
        return context.l10n.statusPartiallyPaid;
      case BillStatus.unpaid:
        return context.l10n.statusUnpaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _getLabel(context),
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
