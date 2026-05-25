import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/update_note_usecase.dart';

import 'note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final IdGenerator idGenerator;

  NoteEditorCubit({
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.idGenerator,
  }) : super(const NoteEditorState());

  Future<void> saveNote({
    required String? noteId,
    required String memoryBoxId,
    required String authorId,
    required String title,
    required String content,
  }) async {
    emit(state.copyWith(status: NoteEditorStatus.loading));

    try {
      if (noteId == null) {
        final now = DateTime.now().toUtc();

        final note = NoteEntity(
          id: idGenerator.generate(),
          memoryBoxId: memoryBoxId,
          authorId: authorId,
          title: title.trim(),
          content: content,
          createdAt: now,
          updatedAt: now,
        );

        await createNoteUseCase(note: note);
      } else {
        await updateNoteUseCase(noteId: noteId, title: title, content: content);
      }

      emit(state.copyWith(status: NoteEditorStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: NoteEditorStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
