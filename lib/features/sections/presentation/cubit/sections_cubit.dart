import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/domain/usecases/delete_section_usecase.dart';
import 'package:memory_chat/features/sections/domain/usecases/get_sections_usecase.dart';
import 'package:memory_chat/features/sections/domain/usecases/rename_section_usecase.dart';

import 'sections_state.dart';

class SectionsCubit extends Cubit<SectionsState> {
  final GetSectionsUseCase getSectionsUseCase;
  final RenameSectionUseCase renameSectionUseCase;
  final DeleteSectionUseCase deleteSectionUseCase;

  SectionsCubit({
    required this.getSectionsUseCase,
    required this.renameSectionUseCase,
    required this.deleteSectionUseCase,
  }) : super(const SectionsState());

  Future<void> loadSections(String workspaceId) async {
    emit(state.copyWith(status: SectionsStatus.loading));

    try {
      final sections = await getSectionsUseCase(workspaceId);
      emit(state.copyWith(status: SectionsStatus.success, sections: sections));
    } catch (e) {
      emit(
        state.copyWith(
          status: SectionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> renameSection({
    required String sectionId,
    required String newTitle,
  }) async {
    try {
      await renameSectionUseCase(sectionId: sectionId, newTitle: newTitle);
      final updatedSections = state.sections.map((section) {
        if (section.id == sectionId) {
          return SectionEntity(
            id: section.id,
            workspaceId: section.workspaceId,
            title: newTitle.trim(),
            createdAt: section.createdAt,
            updatedAt: DateTime.now().toUtc(),
            deletedAt: section.deletedAt,
          );
        }
        return section;
      }).toList();

      emit(state.copyWith(sections: updatedSections));
    } catch (e) {
      emit(
        state.copyWith(
          status: SectionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteSection(String sectionId) async {
    try {
      await deleteSectionUseCase(sectionId: sectionId);
      final filtered = state.sections
          .where((section) => section.id != sectionId)
          .toList();

      emit(state.copyWith(sections: filtered));
    } catch (e) {
      emit(
        state.copyWith(
          status: SectionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
