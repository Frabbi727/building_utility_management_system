import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/features/bills/data/models/bill_model.dart';
import 'package:building_utility_management_system/features/bills/domain/entities/bill_entity.dart';

void main() {
  final json = {
    'id': 1,
    'bill_no': 'BILL-202609-001',
    'billing_month': '2026-09',
    'total_amount': '5200.00',
    'month_charges': '4500.00',
    'arrears': '700.00',
    'due_date': '2026-09-25',
    'status': 'unpaid',
    'items': [
      {
        'id': 101,
        'description': 'Service Charge',
        'amount': '3500.00',
        'quantity': null,
        'unit_rate': null,
        'unit_label': null,
      },
      {
        'id': 102,
        'description': 'Electricity Submeter',
        'amount': '1000.00',
        'quantity': '100',
        'unit_rate': '10.00',
        'unit_label': 'kWh',
      }
    ],
    'created_at': '2026-09-01T00:00:00Z',
  };

  group('BillModel', () {
    test('BillModel parses correctly from json', () {
      final model = BillModel.fromJson(json);
      expect(model.id, 1);
      expect(model.billNo, 'BILL-202609-001');
      expect(model.billingMonth, '2026-09');
      expect(model.totalAmount, '5200.00');
      expect(model.monthCharges, '4500.00');
      expect(model.arrears, '700.00');
      expect(model.status, 'unpaid');
      expect(model.items?.length, 2);
      expect(model.items?.first.description, 'Service Charge');
    });

    test('toEntity maps correctly to BillEntity', () {
      final model = BillModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.billNo, 'BILL-202609-001');
      expect(entity.status, BillStatus.unpaid);
      expect(entity.items.length, 2);
      expect(entity.items[1].unitLabel, 'kWh');
    });
  });
}
