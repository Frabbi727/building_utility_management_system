import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/data/models/flat_model.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import 'latest_bill_model.dart';
import 'notice_snippet_model.dart';
import 'recent_activity_model.dart';
import 'resident_balances_model.dart';

part 'dashboard_data_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DashboardDataModel extends Equatable {
  final FlatModel flat;
  final ResidentBalancesModel balances;

  @JsonKey(name: 'latest_bill')
  final LatestBillModel? latestBill;

  @JsonKey(name: 'active_notices')
  final List<NoticeSnippetModel> activeNotices;

  @JsonKey(name: 'recent_activity')
  final List<RecentActivityModel> recentActivity;

  const DashboardDataModel({
    required this.flat,
    required this.balances,
    this.latestBill,
    this.activeNotices = const [],
    this.recentActivity = const [],
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDataModelToJson(this);

  DashboardDataEntity toEntity() => DashboardDataEntity(
        flat: flat.toEntity(),
        balances: balances.toEntity(),
        latestBill: latestBill?.toEntity(),
        activeNotices: activeNotices.map((n) => n.toEntity()).toList(),
        recentActivity: recentActivity.map((a) => a.toEntity()).toList(),
      );

  @override
  List<Object?> get props => [
        flat,
        balances,
        latestBill,
        activeNotices,
        recentActivity,
      ];
}
