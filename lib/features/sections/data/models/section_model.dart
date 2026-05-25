import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';

class SectionModel extends SectionEntity {
  const SectionModel({
    required super.id,
    required super.workspaceId,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      title: json['title'] as String,
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
      'workspace_id': workspaceId,
      'title': title,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
