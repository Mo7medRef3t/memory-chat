import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';

class MemoryBoxModel extends MemoryBoxEntity {
  const MemoryBoxModel({
    required super.id,
    required super.sectionId,
    required super.title,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory MemoryBoxModel.fromJson(Map<String, dynamic> json) {
    return MemoryBoxModel(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'title': title,
      'description': description,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
