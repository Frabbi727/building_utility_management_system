// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillModel _$BillModelFromJson(Map<String, dynamic> json) => BillModel(
  id: (json['id'] as num).toInt(),
  billNo: json['bill_no'] as String,
  billingMonth: json['billing_month'] as String,
  totalAmount: json['total_amount'],
  monthCharges: json['month_charges'],
  arrears: json['arrears'],
  dueDate: json['due_date'] as String,
  status: json['status'] as String,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$BillModelToJson(BillModel instance) => <String, dynamic>{
  'id': instance.id,
  'bill_no': instance.billNo,
  'billing_month': instance.billingMonth,
  'total_amount': instance.totalAmount,
  'month_charges': instance.monthCharges,
  'arrears': instance.arrears,
  'due_date': instance.dueDate,
  'status': instance.status,
  'items': instance.items,
  'created_at': instance.createdAt,
};
