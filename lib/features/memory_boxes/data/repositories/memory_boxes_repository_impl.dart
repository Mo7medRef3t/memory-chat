import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/sync/powersync_service.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class MemoryBoxesRepositoryImpl implements MemoryBoxesRepository {
  final PowerSyncService _powerSync;

  MemoryBoxesRepositoryImpl() : _powerSync = sl<PowerSyncService>();

  MemoryBoxEntity _rowToEntity(Map<String, dynamic> row) {
    return MemoryBoxEntity(
      id: row['id'] as String,
      workspaceId: row['workspace_id'] as String,
      sectionId: row['section_id'] as String?,
      title: row['title'] as String,
      description: row['description'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Stream<List<MemoryBoxEntity>> getMemoryBoxes({
    required String workspaceId,
    String? sectionId,
  }) {
    if (sectionId != null) {
      return _powerSync.database
          .watch(
            '''SELECT * FROM memory_boxes 
           WHERE workspace_id = ? AND section_id = ? 
           ORDER BY created_at ASC''',
            parameters: [workspaceId, sectionId],
          )
          .map((results) => results.map((row) => _rowToEntity(row)).toList());
    } else {
      return _powerSync.database
          .watch(
            '''SELECT * FROM memory_boxes 
           WHERE workspace_id = ? AND section_id IS NULL 
           ORDER BY created_at ASC''',
            parameters: [workspaceId],
          )
          .map((results) => results.map((row) => _rowToEntity(row)).toList());
    }
  }

  @override
  Future<void> createMemoryBox({required MemoryBoxEntity memoryBox}) async {
    await _powerSync.database.execute(
      '''INSERT INTO memory_boxes (id, workspace_id, section_id, title, description, created_at, updated_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        memoryBox.id,
        memoryBox.workspaceId,
        memoryBox.sectionId,
        memoryBox.title,
        memoryBox.description,
        memoryBox.createdAt.toUtc().toIso8601String(),
        memoryBox.updatedAt.toUtc().toIso8601String(),
      ],
    );
  }

  @override
  Future<void> updateMemoryBox({
    required String memoryBoxId,
    required String title,
    String? description,
  }) async {
    await _powerSync.database.execute(
      '''UPDATE memory_boxes 
         SET title = ?, description = ?, updated_at = ? 
         WHERE id = ?''',
      [
        title,
        description,
        DateTime.now().toUtc().toIso8601String(),
        memoryBoxId,
      ],
    );
  }

  @override
  Future<void> deleteMemoryBox({required String memoryBoxId}) async {
    await _powerSync.database.execute('DELETE FROM memory_boxes WHERE id = ?', [
      memoryBoxId,
    ]);
  }

  @override
  Future<void> moveMemoryBox({
    required String memoryBoxId,
    required String workspaceId,
    String? newSectionId,
  }) async {
    await _powerSync.database.execute(
      '''UPDATE memory_boxes 
         SET workspace_id = ?, section_id = ?, updated_at = ? 
         WHERE id = ?''',
      [
        workspaceId,
        newSectionId,
        DateTime.now().toUtc().toIso8601String(),
        memoryBoxId,
      ],
    );
  }
}
