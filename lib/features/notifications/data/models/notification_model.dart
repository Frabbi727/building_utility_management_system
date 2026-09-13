import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? referenceType;
  final int? referenceId;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'SYSTEM_BROADCAST',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as int?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      referenceType: referenceType,
      referenceId: referenceId,
      isRead: isRead,
      readAt: readAt != null ? DateTime.tryParse(readAt!) : null,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
