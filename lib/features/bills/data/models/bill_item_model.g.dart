// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillItemModel _$BillItemModelFromJson(Map<String, dynamic> json) =>
    BillItemModel(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String,
      amount: json['amount'],
      quantity: json['quantity'],
      unitRate: json['unit_rate'],
      unitLabel: json['unit_label'] as String?,
    );

Map<String, dynamic> _$BillItemModelToJson(BillItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'unit_rate': instance.unitRate,
      'unit_label': instance.unitLabel,
    };
