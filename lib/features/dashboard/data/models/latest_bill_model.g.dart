// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_bill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestBillModel _$LatestBillModelFromJson(Map<String, dynamic> json) =>
    LatestBillModel(
      id: (json['id'] as num).toInt(),
      billNo: json['bill_no'] as String,
      billingMonth: json['billing_month'] as String,
      totalAmount: json['total_amount'] as String,
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$LatestBillModelToJson(LatestBillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bill_no': instance.billNo,
      'billing_month': instance.billingMonth,
      'total_amount': instance.totalAmount,
      'due_date': instance.dueDate,
      'status': instance.status,
    };
