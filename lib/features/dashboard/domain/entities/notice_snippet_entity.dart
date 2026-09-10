import 'package:equatable/equatable.dart';

class NoticeSnippetEntity extends Equatable {
  final int id;
  final String title;
  final String? content;
  final String publishedAt;

  const NoticeSnippetEntity({
    required this.id,
    required this.title,
    this.content,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        publishedAt,
      ];
}
