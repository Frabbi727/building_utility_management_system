import 'package:building_utility_management_system/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:building_utility_management_system/features/dashboard/data/models/latest_bill_model.dart';
import 'package:building_utility_management_system/features/dashboard/data/models/notice_snippet_model.dart';
import 'package:building_utility_management_system/features/dashboard/data/models/recent_activity_model.dart';
import 'package:building_utility_management_system/features/dashboard/data/models/resident_balances_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const flatJson = <String, dynamic>{
    'id': 1,
    'number': 'A-101',
    'floor': '1st',
    'building_id': 10,
    'building_name': 'Tower A',
  };

  const balancesJson = <String, dynamic>{
    'total_due': '5000.00',
    'advance_held': '0.00',
    'current_month_charges': '5000.00',
    'arrears': '0.00',
  };

  const billJson = <String, dynamic>{
    'id': 10,
    'bill_no': 'SCB-2026-09-01',
    'billing_month': '2026-09',
    'total_amount': '5000.00',
    'due_date': '2026-09-15',
    'status': 'unpaid',
  };

  const noticeJson = <String, dynamic>{
    'id': 1,
    'title': 'Water shutdown notice',
    'content': 'Water supply will be paused from 10 AM to 1 PM',
    'published_at': '2026-09-10',
  };

  const activityJson = <String, dynamic>{
    'id': 1,
    'type': 'payment',
    'title': 'Utility Payment',
    'amount': '5000.00',
    'date': '2026-09-08',
    'status': 'approved',
  };

  final dashboardJson = <String, dynamic>{
    'flat': flatJson,
    'balances': balancesJson,
    'latest_bill': billJson,
    'active_notices': [noticeJson],
    'recent_activity': [activityJson],
  };

  group('Dashboard Models fromJson & toEntity', () {
    test('ResidentBalancesModel deserializes and converts toEntity', () {
      final model = ResidentBalancesModel.fromJson(balancesJson);
      expect(model.totalDue, '5000.00');
      expect(model.advanceHeld, '0.00');
      expect(model.currentMonthCharges, '5000.00');
      expect(model.arrears, '0.00');

      final entity = model.toEntity();
      expect(entity.totalDue, '5000.00');
      expect(entity.hasOutstandingDue, isTrue);
    });

    test('LatestBillModel deserializes and converts toEntity', () {
      final model = LatestBillModel.fromJson(billJson);
      expect(model.id, 10);
      expect(model.billNo, 'SCB-2026-09-01');
      expect(model.billingMonth, '2026-09');
      expect(model.totalAmount, '5000.00');
      expect(model.dueDate, '2026-09-15');
      expect(model.status, 'unpaid');

      final entity = model.toEntity();
      expect(entity.isPaid, isFalse);
    });

    test('NoticeSnippetModel deserializes and converts toEntity', () {
      final model = NoticeSnippetModel.fromJson(noticeJson);
      expect(model.id, 1);
      expect(model.title, 'Water shutdown notice');
      expect(model.content, contains('Water supply'));
      expect(model.publishedAt, '2026-09-10');

      final entity = model.toEntity();
      expect(entity.title, 'Water shutdown notice');
    });

    test('RecentActivityModel deserializes and converts toEntity', () {
      final model = RecentActivityModel.fromJson(activityJson);
      expect(model.id, 1);
      expect(model.type, 'payment');
      expect(model.title, 'Utility Payment');
      expect(model.amount, '5000.00');
      expect(model.date, '2026-09-08');
      expect(model.status, 'approved');

      final entity = model.toEntity();
      expect(entity.amount, '5000.00');
    });

    test('DashboardDataModel deserializes full payload and converts toEntity', () {
      final model = DashboardDataModel.fromJson(dashboardJson);
      expect(model.flat.number, 'A-101');
      expect(model.balances.totalDue, '5000.00');
      expect(model.latestBill?.billNo, 'SCB-2026-09-01');
      expect(model.activeNotices.length, 1);
      expect(model.recentActivity.length, 1);

      final entity = model.toEntity();
      expect(entity.flat.number, 'A-101');
      expect(entity.balances.totalDue, '5000.00');
      expect(entity.latestBill?.billNo, 'SCB-2026-09-01');
      expect(entity.activeNotices.length, 1);
      expect(entity.recentActivity.length, 1);
    });

    test('DashboardDataModel handles null latestBill and empty collections', () {
      final jsonWithoutOptional = <String, dynamic>{
        'flat': flatJson,
        'balances': balancesJson,
        'latest_bill': null,
        'active_notices': <dynamic>[],
        'recent_activity': <dynamic>[],
      };
      final model = DashboardDataModel.fromJson(jsonWithoutOptional);
      expect(model.latestBill, isNull);
      expect(model.activeNotices, isEmpty);
      expect(model.recentActivity, isEmpty);

      final entity = model.toEntity();
      expect(entity.latestBill, isNull);
      expect(entity.activeNotices, isEmpty);
      expect(entity.recentActivity, isEmpty);
    });

    test('Models defensively parse numeric and string IDs/amounts', () {
      final numericBalances = ResidentBalancesModel.fromJson(const {
        'total_due': 5000,
        'advance_held': 100.5,
        'current_month_charges': 4900,
        'arrears': 0,
      });
      expect(numericBalances.totalDue, '5000');
      expect(numericBalances.advanceHeld, '100.5');

      final stringIdBill = LatestBillModel.fromJson(const {
        'id': '42',
        'bill_no': 'B-1',
        'billing_month': '2026-09',
        'total_amount': 2500,
        'due_date': '2026-09-20',
        'status': 'unpaid',
      });
      expect(stringIdBill.id, 42);
      expect(stringIdBill.totalAmount, '2500');

      final stringIdNotice = NoticeSnippetModel.fromJson(const {
        'id': '99',
        'title': 'Test Notice',
        'published_at': '2026-09-10',
      });
      expect(stringIdNotice.id, 99);

      final stringIdActivity = RecentActivityModel.fromJson(const {
        'id': '101',
        'type': 'payment',
        'title': 'Pay',
        'amount': 300,
        'date': '2026-09-09',
        'status': 'completed',
      });
      expect(stringIdActivity.id, 101);
      expect(stringIdActivity.amount, '300');
    });

    test('Models support toJson serialization and Equatable equality', () {
      final model = DashboardDataModel.fromJson(dashboardJson);
      final json = model.toJson();
      final roundTrip = DashboardDataModel.fromJson(json);

      expect(roundTrip, equals(model));
      expect(model.balances.props, isNotEmpty);
      expect(model.latestBill?.props, isNotEmpty);
    });
  });
}
