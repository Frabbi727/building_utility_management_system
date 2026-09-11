// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resident_balances_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResidentBalancesModel _$ResidentBalancesModelFromJson(
  Map<String, dynamic> json,
) => ResidentBalancesModel(
  totalDue: ResidentBalancesModel._stringFromDynamic(json['total_due']),
  advanceHeld: ResidentBalancesModel._stringFromDynamic(json['advance_held']),
  currentMonthCharges: ResidentBalancesModel._stringFromDynamic(
    json['current_month_charges'],
  ),
  arrears: ResidentBalancesModel._stringFromDynamic(json['arrears']),
);

Map<String, dynamic> _$ResidentBalancesModelToJson(
  ResidentBalancesModel instance,
) => <String, dynamic>{
  'total_due': instance.totalDue,
  'advance_held': instance.advanceHeld,
  'current_month_charges': instance.currentMonthCharges,
  'arrears': instance.arrears,
};
