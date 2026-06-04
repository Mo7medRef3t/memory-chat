import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/sync/powersync_service.dart';
import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';

class WorkspacesRepositoryImpl implements WorkspacesRepository {
  final PowerSyncService _powerSync;
  final IdGenerator _idGenerator;

  WorkspacesRepositoryImpl() 
      : _powerSync = sl<PowerSyncService>(),
        _idGenerator = sl<IdGenerator>();

  WorkspaceEntity _rowToEntity(Map<String, dynamic> row) {
    return WorkspaceEntity(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      ownerId: row['owner_id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Stream<List<WorkspaceEntity>> getUserWorkspaces(String userId) {
    return _powerSync.database.watch(
      '''SELECT * FROM workspaces 
         WHERE owner_id = ? 
         OR id IN (SELECT workspace_id FROM workspace_members WHERE user_id = ?)
         ORDER BY created_at ASC''',
      parameters: [userId, userId],
    ).map((results) => results.map((row) => _rowToEntity(row)).toList());
  }

  @override
  Future<void> createWorkspace({
    required WorkspaceEntity workspace,
    required String currentUserId,
  }) async {
    await _powerSync.database.execute(
      '''INSERT INTO workspaces (id, name, description, owner_id, created_at, updated_at) 
         VALUES (?, ?, ?, ?, ?, ?)''',
      [
        workspace.id,
        workspace.name,
        workspace.description,
        workspace.ownerId,
        workspace.createdAt.toUtc().toIso8601String(),
        workspace.updatedAt.toUtc().toIso8601String(),
      ],
    );

    final membershipId = _idGenerator.generate();
    await _powerSync.database.execute(
      '''INSERT INTO workspace_members (id, workspace_id, user_id, role, joined_at) 
         VALUES (?, ?, ?, 'owner', ?)''',
      [
        membershipId, 
        workspace.id,
        currentUserId,
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }

  @override
  Future<void> updateWorkspace({
    required String workspaceId,
    required String name,
    String? description,
  }) async {
    await _powerSync.database.execute(
      '''UPDATE workspaces 
         SET name = ?, description = ?, updated_at = ? 
         WHERE id = ?''',
      [
        name,
        description,
        DateTime.now().toUtc().toIso8601String(),
        workspaceId,
      ],
    );
  }

  @override
  Future<void> deleteWorkspace({required String workspaceId}) async {
    await _powerSync.database.execute(
      'DELETE FROM workspace_members WHERE workspace_id = ?',
      [workspaceId],
    );
    
    await _powerSync.database.execute(
      'DELETE FROM workspaces WHERE id = ?',
      [workspaceId],
    );
  }
}