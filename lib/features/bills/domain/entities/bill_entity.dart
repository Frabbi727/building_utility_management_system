import 'package:equatable/equatable.dart';
import 'bill_item_entity.dart';

enum BillStatus {
  unpaid,
  partiallyPaid,
  paid;

  static BillStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'paid':
        return BillStatus.paid;
      case 'partially_paid':
      case 'partiallypaid':
        return BillStatus.partiallyPaid;
      case 'unpaid':
      default:
        return BillStatus.unpaid;
    }
  }

  String get value {
    switch (this) {
      case BillStatus.paid:
        return 'paid';
      case BillStatus.partiallyPaid:
        return 'partially_paid';
      case BillStatus.unpaid:
        return 'unpaid';
    }
  }
}

class BillEntity extends Equatable {
  final int id;
  final String billNo;
  final String? title;
  final String billingMonth;
  final String? billingMonthFormatted;
  final String totalAmount;
  final String? monthCharges;
  final String? arrears;
  final String dueDate;
  final BillStatus status;
  final List<BillItemEntity> items;
  final String createdAt;

  const BillEntity({
    required this.id,
    required this.billNo,
    this.title,
    required this.billingMonth,
    this.billingMonthFormatted,
    required this.totalAmount,
    this.monthCharges,
    this.arrears,
    required this.dueDate,
    required this.status,
    this.items = const [],
    required this.createdAt,
  });

  bool get isPaid => status == BillStatus.paid;

  String get displayTitle =>
      (title != null && title!.trim().isNotEmpty) ? title! : '$billingMonth Bill';

  @override
  List<Object?> get props => [
        id,
        billNo,
        title,
        billingMonth,
        billingMonthFormatted,
        totalAmount,
        monthCharges,
        arrears,
        dueDate,
        status,
        items,
        createdAt,
      ];
}
