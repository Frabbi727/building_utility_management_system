import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/flat_entity.dart';

part 'flat_model.g.dart';

@JsonSerializable()
class FlatModel extends Equatable {
  final int id;
  final String number;
  final String floor;
  @JsonKey(name: 'building_id')
  final int buildingId;
  @JsonKey(name: 'building_name')
  final String buildingName;

  const FlatModel({
    required this.id,
    required this.number,
    required this.floor,
    required this.buildingId,
    required this.buildingName,
  });

  factory FlatModel.fromJson(Map<String, dynamic> json) =>
      _$FlatModelFromJson(json);
  Map<String, dynamic> toJson() => _$FlatModelToJson(this);

  FlatEntity toEntity() => FlatEntity(
        id: id,
        number: number,
        floor: floor,
        buildingId: buildingId,
        buildingName: buildingName,
      );

  @override
  List<Object?> get props => [id, number, floor, buildingId, buildingName];
}
