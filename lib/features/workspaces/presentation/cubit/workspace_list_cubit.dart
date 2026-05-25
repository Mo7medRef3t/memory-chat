import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/get_user_workspaces_usecase.dart';

import 'workspace_list_state.dart';

class WorkspaceListCubit extends Cubit<WorkspaceListState> {
  final GetUserWorkspacesUseCase getUserWorkspacesUseCase;

  WorkspaceListCubit(this.getUserWorkspacesUseCase)
    : super(const WorkspaceListState());

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
}
