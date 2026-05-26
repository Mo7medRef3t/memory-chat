import 'package:equatable/equatable.dart';

class SectionEntity extends Equatable {
  final String id;
  final String workspaceId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SectionEntity({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, workspaceId, title, createdAt, updatedAt];
}
