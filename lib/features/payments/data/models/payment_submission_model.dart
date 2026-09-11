import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_submission_entity.dart';

part 'payment_submission_model.g.dart';

@JsonSerializable()
class PaymentSubmissionModel {
  final int id;
  final String amount;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'reference_number')
  final String referenceNumber;
  @JsonKey(name: 'payment_date')
  final String paymentDate;
  @JsonKey(name: 'slip_url')
  final String? slipUrl;
  @JsonKey(name: 'resident_notes')
  final String? residentNotes;
  final String status;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const PaymentSubmissionModel({
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

  factory PaymentSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentSubmissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSubmissionModelToJson(this);

  PaymentSubmissionEntity toEntity() => PaymentSubmissionEntity(
        id: id,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        paymentDate: paymentDate,
        slipUrl: slipUrl,
        residentNotes: residentNotes,
        status: PaymentSubmissionStatus.fromString(status),
        rejectionReason: rejectionReason,
        createdAt: createdAt,
      );
}
