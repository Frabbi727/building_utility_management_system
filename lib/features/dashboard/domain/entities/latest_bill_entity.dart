import 'package:equatable/equatable.dart';

class LatestBillEntity extends Equatable {
  final int id;
  final String billNo;
  final String billingMonth;
  final String totalAmount;
  final String dueDate;
  final String status;

  const LatestBillEntity({
    required this.id,
    required this.billNo,
    required this.billingMonth,
    required this.totalAmount,
    required this.dueDate,
    required this.status,
  });

  bool get isPaid => status.trim().toLowerCase() == 'paid';

  @override
  List<Object?> get props => [
        id,
        billNo,
        billingMonth,
        totalAmount,
        dueDate,
        status,
      ];
}
