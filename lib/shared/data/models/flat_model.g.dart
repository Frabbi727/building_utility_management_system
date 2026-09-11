// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlatModel _$FlatModelFromJson(Map<String, dynamic> json) => FlatModel(
  id: (json['id'] as num).toInt(),
  number: json['number'] as String,
  floor: json['floor'] as String,
  buildingId: (json['building_id'] as num).toInt(),
  buildingName: json['building_name'] as String,
);

Map<String, dynamic> _$FlatModelToJson(FlatModel instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'floor': instance.floor,
  'building_id': instance.buildingId,
  'building_name': instance.buildingName,
};
