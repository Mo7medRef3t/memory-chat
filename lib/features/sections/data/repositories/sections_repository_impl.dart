import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/sync/powersync_service.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';

class SectionsRepositoryImpl implements SectionsRepository {
  final PowerSyncService _powerSync;

  SectionsRepositoryImpl() : _powerSync = sl<PowerSyncService>();

  SectionEntity _rowToEntity(Map<String, dynamic> row) {
    return SectionEntity(
      id: row['id'] as String,
      workspaceId: row['workspace_id'] as String,
      title: row['title'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Stream<List<SectionEntity>> getSections(String workspaceId) {
    return _powerSync.database
        .watch(
          'SELECT * FROM sections WHERE workspace_id = ? ORDER BY created_at ASC',
          parameters: [workspaceId],
        )
        .map((results) => results.map((row) => _rowToEntity(row)).toList());
  }

  @override
  Future<void> createSection({required SectionEntity section}) async {
    await _powerSync.database.execute(
      '''INSERT INTO sections (id, workspace_id, title, created_at, updated_at) 
         VALUES (?, ?, ?, ?, ?)''',
      [
        section.id,
        section.workspaceId,
        section.title,
        section.createdAt.toUtc().toIso8601String(),
        section.updatedAt.toUtc().toIso8601String(),
      ],
    );
  }

  @override
  Future<void> renameSection({
    required String sectionId,
    required String newTitle,
  }) async {
    await _powerSync.database.execute(
      '''UPDATE sections 
         SET title = ?, updated_at = ? 
         WHERE id = ?''',
      [newTitle, DateTime.now().toUtc().toIso8601String(), sectionId],
    );
  }

  @override
  Future<void> deleteSection({required String sectionId}) async {
    await _powerSync.database.execute('DELETE FROM sections WHERE id = ?', [
      sectionId,
    ]);
  }
}
