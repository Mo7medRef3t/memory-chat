import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/usecases/create_memory_box_usecase.dart';

import 'create_memory_box_state.dart';

class CreateMemoryBoxCubit extends Cubit<CreateMemoryBoxState> {
  final CreateMemoryBoxUseCase createMemoryBoxUseCase;
  final IdGenerator idGenerator;

  CreateMemoryBoxCubit({
    required this.createMemoryBoxUseCase,
    required this.idGenerator,
  }) : super(const CreateMemoryBoxState());

  Future<void> createMemoryBox({
    required String workspaceId,
    String? sectionId,
    required String title,
    String? description,
  }) async {
    emit(state.copyWith(status: CreateMemoryBoxStatus.loading));

    try {
      final now = DateTime.now().toUtc();

      final memoryBox = MemoryBoxEntity(
        id: idGenerator.generate(),
        workspaceId: workspaceId, 
        sectionId: sectionId,
        title: title.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await createMemoryBoxUseCase(memoryBox: memoryBox);

      emit(state.copyWith(status: CreateMemoryBoxStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateMemoryBoxStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
