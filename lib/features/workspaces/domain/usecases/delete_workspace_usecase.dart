import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';

class DeleteWorkspaceUseCase {
  final WorkspacesRepository repository;
  DeleteWorkspaceUseCase(this.repository);

  Future<void> call({required String workspaceId}) {
    return repository.deleteWorkspace(workspaceId: workspaceId);
  }
}
