import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import 'latest_bill_entity.dart';
import 'notice_snippet_entity.dart';
import 'recent_activity_entity.dart';
import 'resident_balances_entity.dart';

class DashboardDataEntity extends Equatable {
  final FlatEntity flat;
  final ResidentBalancesEntity balances;
  final LatestBillEntity? latestBill;
  final List<NoticeSnippetEntity> activeNotices;
  final List<RecentActivityEntity> recentActivity;

  const DashboardDataEntity({
    required this.flat,
    required this.balances,
    this.latestBill,
    this.activeNotices = const [],
    this.recentActivity = const [],
  });

  @override
  List<Object?> get props => [
        flat,
        balances,
        latestBill,
        activeNotices,
        recentActivity,
      ];
}
