// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentSubmissionModel _$PaymentSubmissionModelFromJson(
  Map<String, dynamic> json,
) => PaymentSubmissionModel(
  id: (json['id'] as num).toInt(),
  amount: json['amount'] as String,
  paymentMethod: json['payment_method'] as String,
  referenceNumber: json['reference_number'] as String,
  paymentDate: json['payment_date'] as String,
  slipUrl: json['slip_url'] as String?,
  residentNotes: json['resident_notes'] as String?,
  status: json['status'] as String,
  rejectionReason: json['rejection_reason'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$PaymentSubmissionModelToJson(
  PaymentSubmissionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'payment_method': instance.paymentMethod,
  'reference_number': instance.referenceNumber,
  'payment_date': instance.paymentDate,
  'slip_url': instance.slipUrl,
  'resident_notes': instance.residentNotes,
  'status': instance.status,
  'rejection_reason': instance.rejectionReason,
  'created_at': instance.createdAt,
};
