import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/mappers/entity_mappers.dart';
import 'package:memory_chat/core/database/tables/memory_boxes_table.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';

part 'memory_boxes_dao.g.dart';

@DriftAccessor(tables: [MemoryBoxes])
class MemoryBoxesDao extends DatabaseAccessor<AppDatabase>
    with _$MemoryBoxesDaoMixin {
  MemoryBoxesDao(super.db);

  // ========== READ ==========

  /// Watch memory boxes inside a specific section
  Stream<List<MemoryBoxEntity>> watchBySection(String sectionId) {
    return (select(memoryBoxes)
          ..where((t) => t.sectionId.equals(sectionId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .map((row) => row.toEntity())
        .watch();
  }

  /// Watch memory boxes at workspace root (sectionId is null)
  Stream<List<MemoryBoxEntity>> watchRootBoxes(String workspaceId) {
    return (select(memoryBoxes)
          ..where((t) => t.workspaceId.equals(workspaceId))
          ..where((t) => t.sectionId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .map((row) => row.toEntity())
        .watch();
  }

  /// Watch all memory boxes in workspace (both root + inside sections)
  Stream<List<MemoryBoxEntity>> watchAllByWorkspace(String workspaceId) {
    return (select(memoryBoxes)
          ..where((t) => t.workspaceId.equals(workspaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .map((row) => row.toEntity())
        .watch();
  }

  // ========== WRITE ==========

  Future<void> insertMemoryBox(MemoryBoxEntity entity) {
    return into(memoryBoxes).insert(entity.toCompanion());
  }

  Future<void> updateMemoryBox(MemoryBoxEntity entity) {
    return (update(
      memoryBoxes,
    )..where((t) => t.id.equals(entity.id))).write(entity.toCompanion());
  }

  /// Move memory box to a different section or to workspace root
  Future<void> moveMemoryBox({
    required String memoryBoxId,
    required String newWorkspaceId,
    String? newSectionId, // null = move to workspace root
  }) async {
    await (update(memoryBoxes)..where((t) => t.id.equals(memoryBoxId))).write(
      MemoryBoxesCompanion(
        sectionId: Value(newSectionId),
        workspaceId: Value(newWorkspaceId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteMemoryBox(String id) {
    return (delete(memoryBoxes)..where((t) => t.id.equals(id))).go();
  }

  Future<void> replaceAll(List<MemoryBoxEntity> entities) async {
    await batch((batch) {
      batch.deleteAll(memoryBoxes);
      batch.insertAll(
        memoryBoxes,
        entities.map((e) => e.toCompanion()).toList(),
      );
    });
  }
}
