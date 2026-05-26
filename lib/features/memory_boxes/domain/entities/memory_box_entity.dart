import 'package:equatable/equatable.dart';

class MemoryBoxEntity extends Equatable {
  final String id;
  final String workspaceId; // Always present
  final String? sectionId; // Nullable (null = root level in workspace)
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemoryBoxEntity({
    required this.id,
    required this.workspaceId,
    this.sectionId,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Is this memory box at workspace root level?
  bool get isAtRoot => sectionId == null;

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    sectionId,
    title,
    description,
    createdAt,
    updatedAt,
  ];
}
