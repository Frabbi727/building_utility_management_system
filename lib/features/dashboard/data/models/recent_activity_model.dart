import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/recent_activity_entity.dart';

part 'recent_activity_model.g.dart';

@JsonSerializable()
class RecentActivityModel extends Equatable {
  @JsonKey(fromJson: _idFromJson)
  final int id;
  final String type;
  final String title;
  @JsonKey(fromJson: _stringFromDynamic)
  final String amount;
  final String date;
  final String status;

  static int _idFromJson(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _stringFromDynamic(Object? value) =>
      value?.toString() ?? '0.00';

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
