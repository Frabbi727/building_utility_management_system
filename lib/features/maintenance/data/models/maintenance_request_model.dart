import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/maintenance_request_entity.dart';

part 'maintenance_request_model.g.dart';

@JsonSerializable()
class MaintenanceRequestModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  @JsonKey(name: 'assigned_staff')
  final String? assignedStaff;
  @JsonKey(name: 'assigned_vendor')
  final String? assignedVendor;
  @JsonKey(name: 'resolution_notes')
  final String? resolutionNotes;
  @JsonKey(name: 'resolved_at')
  final String? resolvedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const MaintenanceRequestModel({
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

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceRequestModelToJson(this);

  MaintenanceRequestEntity toEntity() => MaintenanceRequestEntity(
        id: id,
        title: title,
        description: description,
        category: MaintenanceCategory.fromString(category),
        priority: MaintenancePriority.fromString(priority),
        status: MaintenanceStatus.fromString(status),
        assignedStaff: assignedStaff,
        assignedVendor: assignedVendor,
        resolutionNotes: resolutionNotes,
        resolvedAt: resolvedAt,
        createdAt: createdAt,
      );
}
