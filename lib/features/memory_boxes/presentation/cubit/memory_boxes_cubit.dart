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

  MemoryBoxesCubit({
    required this.getMemoryBoxesUseCase,
    required this.updateMemoryBoxUseCase,
    required this.deleteMemoryBoxUseCase,
    required this.moveMemoryBoxUseCase, 
  }) : super(const MemoryBoxesState());

  /// Load boxes either for a section OR root-level (sectionId = null)
  Future<void> loadMemoryBoxes({
    required String workspaceId,
    String? sectionId,
  }) async {
    emit(state.copyWith(status: MemoryBoxesStatus.loading));

    try {
      final memoryBoxes = await getMemoryBoxesUseCase(
        workspaceId: workspaceId,
        sectionId: sectionId,
      );
      emit(
        state.copyWith(
          status: MemoryBoxesStatus.success,
          memoryBoxes: memoryBoxes,
        ),
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

      final updated = state.memoryBoxes.map((box) {
        if (box.id == memoryBoxId) {
          return MemoryBoxEntity(
            id: box.id,
            workspaceId: box.workspaceId,
            sectionId: box.sectionId,
            title: title.trim(),
            description: description?.trim().isEmpty == true
                ? null
                : description?.trim(),
            createdAt: box.createdAt,
            updatedAt: DateTime.now().toUtc(),
          );
        }
        return box;
      }).toList();

      emit(state.copyWith(memoryBoxes: updated));
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

      if (newSectionId != null) {
        final filtered = state.memoryBoxes
            .where((box) => box.id != memoryBoxId)
            .toList();
        emit(state.copyWith(memoryBoxes: filtered));
      } else {
        await loadMemoryBoxes(workspaceId: workspaceId, sectionId: null);
      }
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
      final filtered = state.memoryBoxes
          .where((box) => box.id != memoryBoxId)
          .toList();
      emit(state.copyWith(memoryBoxes: filtered));
    } catch (e) {
      emit(
        state.copyWith(
          status: MemoryBoxesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
