import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final int id;
  final String receiptNo;
  final String amount;
  final String method;
  final String reference;
  final String receivedOn;
  final String receiptUrl;
  final String createdAt;

  const PaymentEntity({
    required this.id,
    required this.receiptNo,
    required this.amount,
    required this.method,
    required this.reference,
    required this.receivedOn,
    required this.receiptUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        receiptNo,
        amount,
        method,
        reference,
        receivedOn,
        receiptUrl,
        createdAt,
      ];
}
