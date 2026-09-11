import 'package:equatable/equatable.dart';

enum PaymentSubmissionStatus {
  pending,
  approved,
  rejected;

  static PaymentSubmissionStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'approved':
        return PaymentSubmissionStatus.approved;
      case 'rejected':
        return PaymentSubmissionStatus.rejected;
      case 'pending':
      default:
        return PaymentSubmissionStatus.pending;
    }
  }

  String get value => name;
}

class PaymentSubmissionEntity extends Equatable {
  final int id;
  final String amount;
  final String paymentMethod;
  final String referenceNumber;
  final String paymentDate;
  final String? slipUrl;
  final String? residentNotes;
  final PaymentSubmissionStatus status;
  final String? rejectionReason;
  final String createdAt;

  const PaymentSubmissionEntity({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.paymentDate,
    this.slipUrl,
    this.residentNotes,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        paymentMethod,
        referenceNumber,
        paymentDate,
        slipUrl,
        residentNotes,
        status,
        rejectionReason,
        createdAt,
      ];
}
