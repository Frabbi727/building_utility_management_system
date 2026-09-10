import 'package:building_utility_management_system/features/dashboard/domain/entities/dashboard_data_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/latest_bill_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/notice_snippet_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/recent_activity_entity.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/resident_balances_entity.dart';
import 'package:building_utility_management_system/shared/domain/entities/flat_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResidentBalancesEntity', () {
    test('hasOutstandingDue returns true when totalDue is positive number', () {
      const balances = ResidentBalancesEntity(
        totalDue: '500.00',
        advanceHeld: '0.00',
        currentMonthCharges: '500.00',
        arrears: '0.00',
      );
      expect(balances.hasOutstandingDue, isTrue);

      const formattedBalances = ResidentBalancesEntity(
        totalDue: '1,500.00',
        advanceHeld: '0.00',
        currentMonthCharges: '1,500.00',
        arrears: '0.00',
      );
      expect(formattedBalances.hasOutstandingDue, isTrue);
    });

    test('hasOutstandingDue returns false when totalDue is zero or negative or unparseable', () {
      const zeroBalances = ResidentBalancesEntity(
        totalDue: '0.00',
        advanceHeld: '100.00',
        currentMonthCharges: '0.00',
        arrears: '0.00',
      );
      expect(zeroBalances.hasOutstandingDue, isFalse);

      const negativeBalances = ResidentBalancesEntity(
        totalDue: '-10.00',
        advanceHeld: '100.00',
        currentMonthCharges: '0.00',
        arrears: '0.00',
      );
      expect(negativeBalances.hasOutstandingDue, isFalse);

      const invalidBalances = ResidentBalancesEntity(
        totalDue: 'invalid',
        advanceHeld: '0.00',
        currentMonthCharges: '0.00',
        arrears: '0.00',
      );
      expect(invalidBalances.hasOutstandingDue, isFalse);
    });

    test('supports value equality via Equatable', () {
      const b1 = ResidentBalancesEntity(
        totalDue: '10.00',
        advanceHeld: '0.00',
        currentMonthCharges: '10.00',
        arrears: '0.00',
      );
      const b2 = ResidentBalancesEntity(
        totalDue: '10.00',
        advanceHeld: '0.00',
        currentMonthCharges: '10.00',
        arrears: '0.00',
      );
      const b3 = ResidentBalancesEntity(
        totalDue: '20.00',
        advanceHeld: '0.00',
        currentMonthCharges: '20.00',
        arrears: '0.00',
      );
      expect(b1, equals(b2));
      expect(b1 == b3, isFalse);
    });
  });

  group('LatestBillEntity', () {
    test('isPaid returns true when status is paid case-insensitively', () {
      const paidBill = LatestBillEntity(
        id: 1,
        billNo: 'B-1',
        billingMonth: '2026-09',
        totalAmount: '1000.00',
        dueDate: '2026-09-15',
        status: 'PAID',
      );
      expect(paidBill.isPaid, isTrue);

      const paidLowerBill = LatestBillEntity(
        id: 1,
        billNo: 'B-1',
        billingMonth: '2026-09',
        totalAmount: '1000.00',
        dueDate: '2026-09-15',
        status: 'paid',
      );
      expect(paidLowerBill.isPaid, isTrue);

      const paidTrimmedBill = LatestBillEntity(
        id: 1,
        billNo: 'B-1',
        billingMonth: '2026-09',
        totalAmount: '1000.00',
        dueDate: '2026-09-15',
        status: '  paid  ',
      );
      expect(paidTrimmedBill.isPaid, isTrue);
    });

    test('isPaid returns false when status is not paid', () {
      const unpaidBill = LatestBillEntity(
        id: 1,
        billNo: 'B-1',
        billingMonth: '2026-09',
        totalAmount: '1000.00',
        dueDate: '2026-09-15',
        status: 'unpaid',
      );
      expect(unpaidBill.isPaid, isFalse);
    });

    test('supports value equality via Equatable', () {
      const bill1 = LatestBillEntity(
        id: 1,
        billNo: 'B-1',
        billingMonth: '2026-09',
        totalAmount: '1000.00',
        dueDate: '2026-09-15',
        status: 'paid',
      );
      const bill2 = LatestBillEntity(
        id: 1,
        billNo: 'B-1',
        billingMonth: '2026-09',
        totalAmount: '1000.00',
        dueDate: '2026-09-15',
        status: 'paid',
      );
      expect(bill1, equals(bill2));
    });
  });

  group('NoticeSnippetEntity', () {
    test('supports value equality via Equatable', () {
      const notice1 = NoticeSnippetEntity(
        id: 1,
        title: 'Notice 1',
        content: 'Content 1',
        publishedAt: '2026-09-10',
      );
      const notice2 = NoticeSnippetEntity(
        id: 1,
        title: 'Notice 1',
        content: 'Content 1',
        publishedAt: '2026-09-10',
      );
      expect(notice1, equals(notice2));
    });
  });

  group('RecentActivityEntity', () {
    test('supports value equality via Equatable', () {
      const a1 = RecentActivityEntity(
        id: 1,
        type: 'bill',
        title: 'Bill Generated',
        amount: '1000.00',
        date: '2026-09-01',
        status: 'unpaid',
      );
      const a2 = RecentActivityEntity(
        id: 1,
        type: 'bill',
        title: 'Bill Generated',
        amount: '1000.00',
        date: '2026-09-01',
        status: 'unpaid',
      );
      expect(a1, equals(a2));
    });
  });

  group('DashboardDataEntity', () {
    test('supports value equality via Equatable', () {
      const flat = FlatEntity(id: 1, number: '101', floor: '1', buildingId: 2, buildingName: 'Tower');
      const balances = ResidentBalancesEntity(
        totalDue: '10.00',
        advanceHeld: '0.00',
        currentMonthCharges: '10.00',
        arrears: '0.00',
      );
      const data1 = DashboardDataEntity(
        flat: flat,
        balances: balances,
        latestBill: null,
        activeNotices: [],
        recentActivity: [],
      );
      const data2 = DashboardDataEntity(
        flat: flat,
        balances: balances,
        latestBill: null,
        activeNotices: [],
        recentActivity: [],
      );
      expect(data1, equals(data2));
    });
  });
}
