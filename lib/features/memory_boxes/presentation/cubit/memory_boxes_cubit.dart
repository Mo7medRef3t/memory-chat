import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/delete_memory_box_usecase.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/get_memory_boxes_usecase.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/move_memory_box_usecase.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/update_memory_box_usecase.dart';
import 'memory_boxes_state.dart';

class MemoryBoxesCubit extends Cubit<MemoryBoxesState> {
  final GetMemoryBoxesUseCase getMemoryBoxesUseCase;
  final UpdateMemoryBoxUseCase updateMemoryBoxUseCase;
  final DeleteMemoryBoxUseCase deleteMemoryBoxUseCase;
  final MoveMemoryBoxUseCase moveMemoryBoxUseCase;

  StreamSubscription<List<MemoryBoxEntity>>? _subscription;

  MemoryBoxesCubit({
    required this.getMemoryBoxesUseCase,
    required this.updateMemoryBoxUseCase,
    required this.deleteMemoryBoxUseCase,
    required this.moveMemoryBoxUseCase,
  }) : super(const MemoryBoxesState());

  void loadMemoryBoxes({required String workspaceId, String? sectionId}) {
    emit(state.copyWith(status: MemoryBoxesStatus.loading));

    _subscription?.cancel();

    _subscription =
        getMemoryBoxesUseCase(
          workspaceId: workspaceId,
          sectionId: sectionId,
        ).listen(
          (memoryBoxes) {
            emit(
              state.copyWith(
                status: MemoryBoxesStatus.success,
                memoryBoxes: memoryBoxes,
              ),
            );
          },
          onError: (e) {
            emit(
              state.copyWith(
                status: MemoryBoxesStatus.failure,
                errorMessage: e.toString(),
              ),
            );
          },
        );
  }

  Future<void> updateMemoryBox({
    required String memoryBoxId,
    required String title,
    String? description,
  }) async {
    try {
      await updateMemoryBoxUseCase(
        memoryBoxId: memoryBoxId,
        title: title,
        description: description,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MemoryBoxesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> moveMemoryBox({
    required String memoryBoxId,
    required String workspaceId,
    String? newSectionId,
  }) async {
    try {
      await moveMemoryBoxUseCase(
        memoryBoxId: memoryBoxId,
        workspaceId: workspaceId,
        newSectionId: newSectionId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MemoryBoxesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteMemoryBox(String memoryBoxId) async {
    try {
      await deleteMemoryBoxUseCase(memoryBoxId: memoryBoxId);
    } catch (e) {
      emit(
        state.copyWith(
          status: MemoryBoxesStatus.failure,
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
