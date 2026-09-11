import 'package:equatable/equatable.dart';

enum MaintenanceCategory {
  plumbing,
  electrical,
  elevator,
  cleaning,
  security,
  other;

  static MaintenanceCategory fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'plumbing':
        return MaintenanceCategory.plumbing;
      case 'electrical':
        return MaintenanceCategory.electrical;
      case 'elevator':
      case 'lift':
        return MaintenanceCategory.elevator;
      case 'cleaning':
        return MaintenanceCategory.cleaning;
      case 'security':
        return MaintenanceCategory.security;
      default:
        return MaintenanceCategory.other;
    }
  }

  String get value => name;
}

enum MaintenancePriority {
  low,
  medium,
  high,
  emergency;

  static MaintenancePriority fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'low':
        return MaintenancePriority.low;
      case 'medium':
        return MaintenancePriority.medium;
      case 'high':
        return MaintenancePriority.high;
      case 'emergency':
      case 'urgent':
        return MaintenancePriority.emergency;
      default:
        return MaintenancePriority.medium;
    }
  }

  String get value => name;
}

enum MaintenanceStatus {
  open,
  inProgress,
  resolved,
  closed;

  static MaintenanceStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'open':
        return MaintenanceStatus.open;
      case 'in_progress':
      case 'inprogress':
        return MaintenanceStatus.inProgress;
      case 'resolved':
        return MaintenanceStatus.resolved;
      case 'closed':
        return MaintenanceStatus.closed;
      default:
        return MaintenanceStatus.open;
    }
  }

  String get value {
    switch (this) {
      case MaintenanceStatus.open:
        return 'open';
      case MaintenanceStatus.inProgress:
        return 'in_progress';
      case MaintenanceStatus.resolved:
        return 'resolved';
      case MaintenanceStatus.closed:
        return 'closed';
    }
  }
}

class MaintenanceRequestEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final MaintenanceCategory category;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final String? assignedStaff;
  final String? assignedVendor;
  final String? resolutionNotes;
  final String? resolvedAt;
  final String createdAt;

  const MaintenanceRequestEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedStaff,
    this.assignedVendor,
    this.resolutionNotes,
    this.resolvedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        priority,
        status,
        assignedStaff,
        assignedVendor,
        resolutionNotes,
        resolvedAt,
        createdAt,
      ];
}
