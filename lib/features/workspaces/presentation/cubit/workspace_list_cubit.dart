import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/delete_workspace_usecase.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/get_user_workspaces_usecase.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/update_workspace_usecase.dart';

import 'workspace_list_state.dart';

class WorkspaceListCubit extends Cubit<WorkspaceListState> {
  final GetUserWorkspacesUseCase getUserWorkspacesUseCase;
  final UpdateWorkspaceUseCase updateWorkspaceUseCase;
  final DeleteWorkspaceUseCase deleteWorkspaceUseCase;

  WorkspaceListCubit({
    required this.getUserWorkspacesUseCase,
    required this.updateWorkspaceUseCase,
    required this.deleteWorkspaceUseCase,
  }) : super(const WorkspaceListState());

  Future<void> loadWorkspaces(String userId) async {
    emit(state.copyWith(status: WorkspaceListStatus.loading));

    try {
      final workspaces = await getUserWorkspacesUseCase(userId);
      emit(
        state.copyWith(
          status: WorkspaceListStatus.success,
          workspaces: workspaces,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkspaceListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> renameWorkspace({
    required String workspaceId,
    required String newName,
    String? newDescription,
  }) async {
    try {
      await updateWorkspaceUseCase(
        workspaceId: workspaceId,
        name: newName,
        description: newDescription,
      );

      final updated = state.workspaces.map((ws) {
        if (ws.id == workspaceId) {
          return WorkspaceEntity(
            id: ws.id,
            name: newName.trim(),
            description: newDescription?.trim().isEmpty == true
                ? null
                : newDescription?.trim(),
            ownerId: ws.ownerId,
            createdAt: ws.createdAt,
            updatedAt: DateTime.now().toUtc(),
          );
        }
        return ws;
      }).toList();

      emit(state.copyWith(workspaces: updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkspaceListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await deleteWorkspaceUseCase(workspaceId: workspaceId);

      final filtered = state.workspaces
          .where((ws) => ws.id != workspaceId)
          .toList();

      emit(state.copyWith(workspaces: filtered));
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkspaceListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
