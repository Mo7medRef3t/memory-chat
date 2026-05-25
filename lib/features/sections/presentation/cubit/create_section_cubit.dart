import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/domain/usecases/create_section_usecase.dart';

import 'create_section_state.dart';

class CreateSectionCubit extends Cubit<CreateSectionState> {
  final CreateSectionUseCase createSectionUseCase;
  final IdGenerator idGenerator;

  CreateSectionCubit({
    required this.createSectionUseCase,
    required this.idGenerator,
  }) : super(const CreateSectionState());

  Future<void> createSection({
    required String workspaceId,
    required String title,
  }) async {
    emit(state.copyWith(status: CreateSectionStatus.loading));

    try {
      final now = DateTime.now().toUtc();

      final section = SectionEntity(
        id: idGenerator.generate(),
        workspaceId: workspaceId,
        title: title.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await createSectionUseCase(section: section);

      emit(state.copyWith(status: CreateSectionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateSectionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
