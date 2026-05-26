import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/mappers/entity_mappers.dart';
import 'package:memory_chat/core/database/tables/workspaces_table.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';

part 'workspaces_dao.g.dart';

@DriftAccessor(tables: [Workspaces])
class WorkspacesDao extends DatabaseAccessor<AppDatabase>
    with _$WorkspacesDaoMixin {
  WorkspacesDao(super.db);

  // ========== READ (Stream-based for reactive UI) ==========

  /// Watch all workspaces owned by or joined by user
  Stream<List<WorkspaceEntity>> watchAllWorkspaces() {
    return select(workspaces).map((row) => row.toEntity()).watch();
  }

  /// Watch single workspace by ID
  Stream<WorkspaceEntity?> watchWorkspaceById(String id) {
    return (select(workspaces)..where((t) => t.id.equals(id)))
        .map((row) => row.toEntity())
        .watchSingleOrNull();
  }

  // ========== WRITE (Local-first) ==========

  Future<void> insertWorkspace(WorkspaceEntity entity) {
    return into(workspaces).insert(entity.toCompanion());
  }

  Future<void> updateWorkspace(WorkspaceEntity entity) {
    return (update(
      workspaces,
    )..where((t) => t.id.equals(entity.id))).write(entity.toCompanion());
  }

  /// Hard Delete
  Future<void> deleteWorkspace(String id) {
    return (delete(workspaces)..where((t) => t.id.equals(id))).go();
  }

  // ========== BULK OPS ==========

  Future<void> replaceAll(List<WorkspaceEntity> entities) async {
    await batch((batch) {
      batch.deleteAll(workspaces);
      batch.insertAll(
        workspaces,
        entities.map((e) => e.toCompanion()).toList(),
      );
    });
  }
}
