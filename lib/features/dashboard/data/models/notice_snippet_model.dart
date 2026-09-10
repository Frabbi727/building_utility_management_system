import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/notice_snippet_entity.dart';

part 'notice_snippet_model.g.dart';

@JsonSerializable()
class NoticeSnippetModel extends Equatable {
  @JsonKey(fromJson: _idFromJson)
  final int id;
  final String title;
  final String? content;

  static int _idFromJson(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @JsonKey(name: 'published_at')
  final String publishedAt;

  const NoticeSnippetModel({
    required this.id,
    required this.title,
    this.content,
    required this.publishedAt,
  });

  factory NoticeSnippetModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeSnippetModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeSnippetModelToJson(this);

  NoticeSnippetEntity toEntity() => NoticeSnippetEntity(
        id: id,
        title: title,
        content: content,
        publishedAt: publishedAt,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        publishedAt,
      ];
}
