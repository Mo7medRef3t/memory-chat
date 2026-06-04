import 'dart:async';
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

  StreamSubscription<List<WorkspaceEntity>>? _subscription;

  WorkspaceListCubit({
    required this.getUserWorkspacesUseCase,
    required this.updateWorkspaceUseCase,
    required this.deleteWorkspaceUseCase,
  }) : super(const WorkspaceListState());

  void loadWorkspaces(String userId) {
    emit(state.copyWith(status: WorkspaceListStatus.loading));

    _subscription?.cancel();

    _subscription = getUserWorkspacesUseCase(userId).listen(
      (workspaces) {
        emit(
          state.copyWith(
            status: WorkspaceListStatus.success,
            workspaces: workspaces,
          ),
        );
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: WorkspaceListStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      },
    );
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
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkspaceListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    super.close();
  }
}
