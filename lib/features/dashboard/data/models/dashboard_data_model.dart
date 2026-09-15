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

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    List<RecentActivityModel> activities = [];
    if (json['recent_activity'] is List && (json['recent_activity'] as List).isNotEmpty) {
      activities = (json['recent_activity'] as List)
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => RecentActivityModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      final payments = json['recent_payments'] as List?;
      if (payments != null) {
        for (final p in payments.whereType<Map<dynamic, dynamic>>()) {
          final pm = Map<String, dynamic>.from(p);
          activities.add(RecentActivityModel(
            id: pm['id'] is int ? pm['id'] as int : int.tryParse(pm['id']?.toString() ?? '') ?? 0,
            type: 'payment',
            title: 'Payment (${pm['receipt_no'] ?? ''}) - ${pm['method'] ?? ''}',
            amount: pm['amount']?.toString() ?? '0.00',
            date: pm['received_on']?.toString() ?? '',
            status: 'paid',
          ));
        }
      }

      final submissions = json['recent_submissions'] as List?;
      if (submissions != null) {
        for (final s in submissions.whereType<Map<dynamic, dynamic>>()) {
          final sm = Map<String, dynamic>.from(s);
          activities.add(RecentActivityModel(
            id: sm['id'] is int ? sm['id'] as int : int.tryParse(sm['id']?.toString() ?? '') ?? 0,
            type: 'payment',
            title: 'Submission (${sm['payment_method'] ?? ''}) - Ref: ${sm['reference_number'] ?? ''}',
            amount: sm['amount']?.toString() ?? '0.00',
            date: sm['payment_date']?.toString() ?? '',
            status: sm['status']?.toString() ?? 'pending',
          ));
        }
      }

      final tickets = json['my_tickets'] as List?;
      if (tickets != null) {
        for (final t in tickets.whereType<Map<dynamic, dynamic>>()) {
          final tm = Map<String, dynamic>.from(t);
          final dateStr = tm['created_at']?.toString() ?? '';
          final shortDate = dateStr.contains('T') ? dateStr.split('T').first : dateStr;
          activities.add(RecentActivityModel(
            id: tm['id'] is int ? tm['id'] as int : int.tryParse(tm['id']?.toString() ?? '') ?? 0,
            type: 'maintenance',
            title: tm['title']?.toString() ?? 'Maintenance Request',
            amount: '0.00',
            date: shortDate,
            status: tm['status']?.toString() ?? 'open',
          ));
        }
      }
    }

    return DashboardDataModel(
      flat: FlatModel.fromJson(Map<String, dynamic>.from(json['flat'] as Map)),
      balances: ResidentBalancesModel.fromJson(Map<String, dynamic>.from(json['balances'] as Map)),
      latestBill: json['latest_bill'] == null
          ? null
          : LatestBillModel.fromJson(Map<String, dynamic>.from(json['latest_bill'] as Map)),
      activeNotices: (json['active_notices'] as List<dynamic>?)
              ?.whereType<Map<dynamic, dynamic>>()
              .map((e) => NoticeSnippetModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      recentActivity: activities,
    );
  }

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
