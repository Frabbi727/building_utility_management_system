import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/recent_activity_entity.dart';

part 'recent_activity_model.g.dart';

@JsonSerializable()
class RecentActivityModel extends Equatable {
  final int id;
  final String type;
  final String title;
  final String amount;
  final String date;
  final String status;

  const RecentActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecentActivityModelToJson(this);

  RecentActivityEntity toEntity() => RecentActivityEntity(
        id: id,
        type: type,
        title: title,
        amount: amount,
        date: date,
        status: status,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        amount,
        date,
        status,
      ];
}
