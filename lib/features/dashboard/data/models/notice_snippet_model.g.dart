// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_snippet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeSnippetModel _$NoticeSnippetModelFromJson(Map<String, dynamic> json) =>
    NoticeSnippetModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String?,
      publishedAt: json['published_at'] as String,
    );

Map<String, dynamic> _$NoticeSnippetModelToJson(NoticeSnippetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'published_at': instance.publishedAt,
    };
