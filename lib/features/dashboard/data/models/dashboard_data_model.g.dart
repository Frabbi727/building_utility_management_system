// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardDataModel _$DashboardDataModelFromJson(
  Map<String, dynamic> json,
) => DashboardDataModel(
  flat: FlatModel.fromJson(json['flat'] as Map<String, dynamic>),
  balances: ResidentBalancesModel.fromJson(
    json['balances'] as Map<String, dynamic>,
  ),
  latestBill: json['latest_bill'] == null
      ? null
      : LatestBillModel.fromJson(json['latest_bill'] as Map<String, dynamic>),
  activeNotices:
      (json['active_notices'] as List<dynamic>?)
          ?.map((e) => NoticeSnippetModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recentActivity:
      (json['recent_activity'] as List<dynamic>?)
          ?.map((e) => RecentActivityModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DashboardDataModelToJson(
  DashboardDataModel instance,
) => <String, dynamic>{
  'flat': instance.flat.toJson(),
  'balances': instance.balances.toJson(),
  'latest_bill': instance.latestBill?.toJson(),
  'active_notices': instance.activeNotices.map((e) => e.toJson()).toList(),
  'recent_activity': instance.recentActivity.map((e) => e.toJson()).toList(),
};
