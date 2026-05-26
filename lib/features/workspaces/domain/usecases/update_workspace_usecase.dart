import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';

class UpdateWorkspaceUseCase {
  final WorkspacesRepository repository;
  UpdateWorkspaceUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String name,
    String? description,
  }) {
    return repository.updateWorkspace(
      workspaceId: workspaceId,
      name: name,
      description: description,
    );
  }
}
