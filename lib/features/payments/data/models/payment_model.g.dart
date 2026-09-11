// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num).toInt(),
  receiptNo: json['receipt_no'] as String,
  amount: json['amount'] as String,
  method: json['method'] as String,
  reference: json['reference'] as String?,
  receivedOn: json['received_on'] as String,
  receiptUrl: json['receipt_url'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'receipt_no': instance.receiptNo,
      'amount': instance.amount,
      'method': instance.method,
      'reference': instance.reference,
      'received_on': instance.receivedOn,
      'receipt_url': instance.receiptUrl,
      'created_at': instance.createdAt,
    };
