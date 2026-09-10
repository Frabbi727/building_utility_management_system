import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/resident_balances_entity.dart';

part 'resident_balances_model.g.dart';

@JsonSerializable()
class ResidentBalancesModel extends Equatable {
  @JsonKey(name: 'total_due', fromJson: _stringFromDynamic)
  final String totalDue;

  @JsonKey(name: 'advance_held', fromJson: _stringFromDynamic)
  final String advanceHeld;

  @JsonKey(name: 'current_month_charges', fromJson: _stringFromDynamic)
  final String currentMonthCharges;

  @JsonKey(name: 'arrears', fromJson: _stringFromDynamic)
  final String arrears;

  static String _stringFromDynamic(Object? value) =>
      value?.toString() ?? '0.00';

  const ResidentBalancesModel({
    required this.totalDue,
    required this.advanceHeld,
    required this.currentMonthCharges,
    required this.arrears,
  });

  factory ResidentBalancesModel.fromJson(Map<String, dynamic> json) =>
      _$ResidentBalancesModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResidentBalancesModelToJson(this);

  ResidentBalancesEntity toEntity() => ResidentBalancesEntity(
        totalDue: totalDue,
        advanceHeld: advanceHeld,
        currentMonthCharges: currentMonthCharges,
        arrears: arrears,
      );

  @override
  List<Object?> get props => [
        totalDue,
        advanceHeld,
        currentMonthCharges,
        arrears,
      ];
}
