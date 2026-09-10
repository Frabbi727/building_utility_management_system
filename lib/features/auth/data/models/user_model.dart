import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String name;
  final String email;
  final String? phone;
  @JsonKey(name: 'is_owner')
  final bool? isOwner;
  @JsonKey(name: 'is_tenant')
  final bool? isTenant;

  static String _idFromJson(Object? id) => id?.toString() ?? '';

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isOwner,
    this.isTenant,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
        isOwner: isOwner,
        isTenant: isTenant,
      );

  @override
  List<Object?> get props => [id, name, email, phone, isOwner, isTenant];
}
