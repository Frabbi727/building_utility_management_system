// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentActivityModel _$RecentActivityModelFromJson(Map<String, dynamic> json) =>
    RecentActivityModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      amount: json['amount'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$RecentActivityModelToJson(
        RecentActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'amount': instance.amount,
      'date': instance.date,
      'status': instance.status,
    };
