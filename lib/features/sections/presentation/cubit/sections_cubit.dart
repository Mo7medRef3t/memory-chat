import 'dart:async';
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

  StreamSubscription<List<SectionEntity>>? _subscription;

  SectionsCubit({
    required this.getSectionsUseCase,
    required this.renameSectionUseCase,
    required this.deleteSectionUseCase,
  }) : super(const SectionsState());

  void loadSections(String workspaceId) {
    emit(state.copyWith(status: SectionsStatus.loading));

    _subscription?.cancel();

    _subscription = getSectionsUseCase(workspaceId).listen(
      (sections) {
        emit(
          state.copyWith(status: SectionsStatus.success, sections: sections),
        );
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: SectionsStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  Future<void> renameSection({
    required String sectionId,
    required String newTitle,
  }) async {
    try {
      await renameSectionUseCase(sectionId: sectionId, newTitle: newTitle);
      // ✅ الـ Stream هيحدث الـ state تلقائياً
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
    } catch (e) {
      emit(
        state.copyWith(
          status: SectionsStatus.failure,
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
