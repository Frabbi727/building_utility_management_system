import 'package:equatable/equatable.dart';

class FlatEntity extends Equatable {
  final int id;
  final String number;
  final String floor;
  final int buildingId;
  final String buildingName;

  const FlatEntity({
    required this.id,
    required this.number,
    required this.floor,
    required this.buildingId,
    required this.buildingName,
  });

  String get displayName => '$number • $buildingName';

  @override
  List<Object?> get props => [id, number, floor, buildingId, buildingName];
}
