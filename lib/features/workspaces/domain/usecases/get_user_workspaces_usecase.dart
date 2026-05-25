import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';

class GetUserWorkspacesUseCase {
  final WorkspacesRepository repository;

  GetUserWorkspacesUseCase(this.repository);

  Future<List<WorkspaceEntity>> call(String userId) {
    return repository.getUserWorkspaces(userId);
  }
}
