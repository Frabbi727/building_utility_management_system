import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/features/payments/data/models/payment_submission_model.dart';
import 'package:building_utility_management_system/features/payments/domain/entities/payment_submission_entity.dart';

void main() {
  final json = {
    'id': 10,
    'amount': '3500.00',
    'payment_method': 'bkash',
    'reference_number': 'TRX9928374',
    'payment_date': '2026-09-11',
    'slip_url': 'http://api.test/storage/payment_slips/sample.jpg',
    'resident_notes': 'September maintenance',
    'status': 'pending',
    'rejection_reason': null,
    'created_at': '2026-09-11T14:30:00Z',
  };

  group('PaymentSubmissionModel', () {
    test('PaymentSubmissionModel parses properly from JSON', () {
      final model = PaymentSubmissionModel.fromJson(json);
      expect(model.id, 10);
      expect(model.amount, '3500.00');
      expect(model.paymentMethod, 'bkash');
      expect(model.referenceNumber, 'TRX9928374');
      expect(model.paymentDate, '2026-09-11');
      expect(model.slipUrl, 'http://api.test/storage/payment_slips/sample.jpg');
      expect(model.status, 'pending');
    });

    test('toEntity maps correctly to PaymentSubmissionEntity', () {
      final model = PaymentSubmissionModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.id, 10);
      expect(entity.amount, '3500.00');
      expect(entity.paymentMethod, 'bkash');
      expect(entity.status, PaymentSubmissionStatus.pending);
    });
  });
}
