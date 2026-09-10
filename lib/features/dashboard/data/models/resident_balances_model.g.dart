// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resident_balances_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResidentBalancesModel _$ResidentBalancesModelFromJson(
        Map<String, dynamic> json) =>
    ResidentBalancesModel(
      totalDue: json['total_due'] as String,
      advanceHeld: json['advance_held'] as String,
      currentMonthCharges: json['current_month_charges'] as String,
      arrears: json['arrears'] as String,
    );

Map<String, dynamic> _$ResidentBalancesModelToJson(
        ResidentBalancesModel instance) =>
    <String, dynamic>{
      'total_due': instance.totalDue,
      'advance_held': instance.advanceHeld,
      'current_month_charges': instance.currentMonthCharges,
      'arrears': instance.arrears,
    };
