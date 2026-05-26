import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';

// ============ Workspace Mappers ============
extension WorkspaceRowMapper on WorkspaceRow {
  WorkspaceEntity toEntity() => WorkspaceEntity(
    id: id,
    name: name,
    description: description,
    ownerId: ownerId,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension WorkspaceEntityMapper on WorkspaceEntity {
  WorkspacesCompanion toCompanion() => WorkspacesCompanion(
    id: Value(id),
    name: Value(name),
    description: Value(description),
    ownerId: Value(ownerId),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}

// ============ Section Mappers ============
extension SectionRowMapper on SectionRow {
  SectionEntity toEntity() => SectionEntity(
    id: id,
    workspaceId: workspaceId,
    title: title,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension SectionEntityMapper on SectionEntity {
  SectionsCompanion toCompanion() => SectionsCompanion(
    id: Value(id),
    workspaceId: Value(workspaceId),
    title: Value(title),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}

// ============ Memory Box Mappers ============
extension MemoryBoxRowMapper on MemoryBoxRow {
  MemoryBoxEntity toEntity() => MemoryBoxEntity(
    id: id,
    workspaceId: workspaceId,
    sectionId: sectionId,
    title: title,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension MemoryBoxEntityMapper on MemoryBoxEntity {
  MemoryBoxesCompanion toCompanion() => MemoryBoxesCompanion(
    id: Value(id),
    workspaceId: Value(workspaceId),
    sectionId: Value(sectionId),
    title: Value(title),
    description: Value(description),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}

// ============ Note Mappers ============
extension NoteRowMapper on NoteRow {
  NoteEntity toEntity() => NoteEntity(
    id: id,
    memoryBoxId: memoryBoxId,
    authorId: authorId,
    title: title,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension NoteEntityMapper on NoteEntity {
  NotesCompanion toCompanion() => NotesCompanion(
    id: Value(id),
    memoryBoxId: Value(memoryBoxId),
    authorId: Value(authorId),
    title: Value(title),
    content: Value(content),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
