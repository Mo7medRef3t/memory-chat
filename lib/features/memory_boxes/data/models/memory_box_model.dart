import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';

class MemoryBoxModel extends MemoryBoxEntity {
  const MemoryBoxModel({
    required super.id,
    required super.workspaceId,
    super.sectionId,
    required super.title,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MemoryBoxModel.fromJson(Map<String, dynamic> json) {
    return MemoryBoxModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      sectionId: json['section_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'section_id': sectionId,
      'title': title,
      'description': description,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  // للـ Convenience
  Map<String, dynamic> toJson() => toInsertJson();
}
