import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/workspaces/domain/entities/workspace_entity.dart';
import 'package:memory_chat/features/workspaces/domain/usecases/create_workspace_usecase.dart';

import 'create_workspace_state.dart';

class CreateWorkspaceCubit extends Cubit<CreateWorkspaceState> {
  final CreateWorkspaceUseCase createWorkspaceUseCase;
  final IdGenerator idGenerator;

  CreateWorkspaceCubit({
    required this.createWorkspaceUseCase,
    required this.idGenerator,
  }) : super(const CreateWorkspaceState());

  Future<void> createWorkspace({
    required String name,
    String? description,
    required String currentUserId,
  }) async {
    emit(state.copyWith(status: CreateWorkspaceStatus.loading));

    try {
      final now = DateTime.now().toUtc();

      final workspace = WorkspaceEntity(
        id: idGenerator.generate(),
        name: name.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        ownerId: currentUserId,
        createdAt: now,
        updatedAt: now,
      );

      await createWorkspaceUseCase(
        workspace: workspace,
        currentUserId: currentUserId,
      );

      emit(state.copyWith(status: CreateWorkspaceStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateWorkspaceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
