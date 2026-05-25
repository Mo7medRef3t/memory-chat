import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/workspaces/data/datasources/workspaces_remote_data_source.dart';
import 'package:memory_chat/features/workspaces/data/models/workspace_model.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/workspaces/domain/repositories/workspaces_repository.dart';

class WorkspacesRepositoryImpl implements WorkspacesRepository {
  final WorkspacesRemoteDataSource remoteDataSource;
  final IdGenerator idGenerator;

  WorkspacesRepositoryImpl({
    required this.remoteDataSource,
    required this.idGenerator,
  });

  @override
  Future<List<WorkspaceEntity>> getUserWorkspaces(String userId) {
    return remoteDataSource.getUserWorkspaces(userId);
  }

  @override
  Future<void> createWorkspace({
    required WorkspaceEntity workspace,
    required String currentUserId,
  }) async {
    final model = WorkspaceModel(
      id: workspace.id,
      name: workspace.name,
      description: workspace.description,
      ownerId: workspace.ownerId,
      createdAt: workspace.createdAt,
      updatedAt: workspace.updatedAt,
      deletedAt: workspace.deletedAt,
    );

    await remoteDataSource.createWorkspace(
      workspace: model,
      membershipId: idGenerator.generate(),
      currentUserId: currentUserId,
    );
  }
}
