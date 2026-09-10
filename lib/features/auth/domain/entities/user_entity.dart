import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool? isOwner;
  final bool? isTenant;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isOwner,
    this.isTenant,
  });

  @override
  List<Object?> get props => [id, name, email, phone, isOwner, isTenant];
}
