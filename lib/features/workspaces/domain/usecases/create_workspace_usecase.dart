import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';

class CreateWorkspaceUseCase {
  final WorkspacesRepository repository;

  CreateWorkspaceUseCase(this.repository);

  Future<void> call({
    required WorkspaceEntity workspace,
    required String currentUserId,
  }) {
    return repository.createWorkspace(
      workspace: workspace,
      currentUserId: currentUserId,
    );
  }
}
