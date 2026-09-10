import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/data/models/flat_model.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthResponseModel extends Equatable {
  final String token;
  final UserModel user;
  final List<FlatModel> flats;

  const AuthResponseModel({
    required this.token,
    required this.user,
    this.flats = const [],
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  @override
  List<Object?> get props => [token, user, flats];
}
