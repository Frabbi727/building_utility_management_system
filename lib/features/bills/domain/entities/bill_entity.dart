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
  final String billingMonth;
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
    required this.billingMonth,
    required this.totalAmount,
    this.monthCharges,
    this.arrears,
    required this.dueDate,
    required this.status,
    this.items = const [],
    required this.createdAt,
  });

  bool get isPaid => status == BillStatus.paid;

  @override
  List<Object?> get props => [
        id,
        billNo,
        billingMonth,
        totalAmount,
        monthCharges,
        arrears,
        dueDate,
        status,
        items,
        createdAt,
      ];
}
