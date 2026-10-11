import 'package:equatable/equatable.dart';

class LatestBillEntity extends Equatable {
  final int id;
  final String billNo;
  final String? title;
  final String billingMonth;
  final String? billingMonthFormatted;
  final String totalAmount;
  final String dueDate;
  final String status;

  const LatestBillEntity({
    required this.id,
    required this.billNo,
    this.title,
    required this.billingMonth,
    this.billingMonthFormatted,
    required this.totalAmount,
    required this.dueDate,
    required this.status,
  });

  bool get isPaid => status.trim().toLowerCase() == 'paid';

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
        dueDate,
        status,
      ];
}
