// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: UserModel._idFromJson(json['id']),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  isOwner: json['is_owner'] as bool?,
  isTenant: json['is_tenant'] as bool?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'is_owner': instance.isOwner,
  'is_tenant': instance.isTenant,
};
