import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String memoryBoxId;
  final String authorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntity({
    required this.id,
    required this.memoryBoxId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    memoryBoxId,
    authorId,
    title,
    content,
    createdAt,
    updatedAt,
  ];
}
