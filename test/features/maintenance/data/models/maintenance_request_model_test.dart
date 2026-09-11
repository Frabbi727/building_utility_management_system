import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/features/maintenance/data/models/maintenance_request_model.dart';
import 'package:building_utility_management_system/features/maintenance/domain/entities/maintenance_request_entity.dart';

void main() {
  final json = {
    'id': 1,
    'title': 'Leaky pipe',
    'description': 'Water leaking under sink',
    'category': 'plumbing',
    'priority': 'high',
    'status': 'open',
    'assigned_staff': 'Rahim Khan',
    'assigned_vendor': null,
    'resolution_notes': null,
    'resolved_at': null,
    'created_at': '2026-09-11T12:00:00Z',
  };

  group('MaintenanceRequestModel', () {
    test('fromJson parses maintenance request correctly', () {
      final model = MaintenanceRequestModel.fromJson(json);
      expect(model.id, 1);
      expect(model.title, 'Leaky pipe');
      expect(model.description, 'Water leaking under sink');
      expect(model.category, 'plumbing');
      expect(model.priority, 'high');
      expect(model.status, 'open');
      expect(model.assignedStaff, 'Rahim Khan');
    });

    test('toEntity maps model to domain entity', () {
      final model = MaintenanceRequestModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.title, 'Leaky pipe');
      expect(entity.category, MaintenanceCategory.plumbing);
      expect(entity.priority, MaintenancePriority.high);
      expect(entity.status, MaintenanceStatus.open);
      expect(entity.assignedStaff, 'Rahim Khan');
    });
  });
}
