// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaintenanceRequestModel _$MaintenanceRequestModelFromJson(
  Map<String, dynamic> json,
) => MaintenanceRequestModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  priority: json['priority'] as String,
  status: json['status'] as String,
  assignedStaff: json['assigned_staff'] as String?,
  assignedVendor: json['assigned_vendor'] as String?,
  resolutionNotes: json['resolution_notes'] as String?,
  resolvedAt: json['resolved_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$MaintenanceRequestModelToJson(
  MaintenanceRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'priority': instance.priority,
  'status': instance.status,
  'assigned_staff': instance.assignedStaff,
  'assigned_vendor': instance.assignedVendor,
  'resolution_notes': instance.resolutionNotes,
  'resolved_at': instance.resolvedAt,
  'created_at': instance.createdAt,
};
