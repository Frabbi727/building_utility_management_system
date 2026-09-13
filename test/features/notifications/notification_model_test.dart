import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/features/notifications/data/models/notification_model.dart';

void main() {
  final json = {
    'id': 42,
    'type': 'BILL_GENERATED',
    'title': 'New Monthly Bill Issued',
    'body': 'Your service charge bill for September 2026 has been issued.',
    'data': {
      'screen': 'bills',
      'reference_id': '101',
      'month': '2026-09',
    },
    'reference_type': 'bill',
    'reference_id': 101,
    'is_read': false,
    'read_at': null,
    'created_at': '2026-09-12T10:30:00Z',
  };

  group('NotificationModel', () {
    test('parses correctly from JSON', () {
      final model = NotificationModel.fromJson(json);

      expect(model.id, 42);
      expect(model.type, 'BILL_GENERATED');
      expect(model.title, 'New Monthly Bill Issued');
      expect(model.body, 'Your service charge bill for September 2026 has been issued.');
      expect(model.data?['screen'], 'bills');
      expect(model.referenceType, 'bill');
      expect(model.referenceId, 101);
      expect(model.isRead, false);
      expect(model.readAt, isNull);
      expect(model.createdAt, '2026-09-12T10:30:00Z');
    });

    test('toEntity maps correctly to NotificationEntity', () {
      final model = NotificationModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, 42);
      expect(entity.type, 'BILL_GENERATED');
      expect(entity.title, 'New Monthly Bill Issued');
      expect(entity.isRead, false);
      expect(entity.referenceId, 101);
      expect(entity.createdAt.year, 2026);
    });

    test('toJson serializes correctly', () {
      final model = NotificationModel.fromJson(json);
      final serialized = model.toJson();

      expect(serialized['id'], 42);
      expect(serialized['type'], 'BILL_GENERATED');
      expect(serialized['title'], 'New Monthly Bill Issued');
      expect(serialized['is_read'], false);
    });
  });
}
