import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';

abstract class WorkspacesRepository {
  Future<List<WorkspaceEntity>> getUserWorkspaces(String userId);

  Future<void> createWorkspace({
    required WorkspaceEntity workspace,
    required String currentUserId,
  });

  Future<void> updateWorkspace({
    required String workspaceId,
    required String name,
    String? description,
  });

  Future<void> deleteWorkspace({required String workspaceId});
}
