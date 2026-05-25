import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/get_notes_usecase.dart';

import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NotesCubit({required this.getNotesUseCase, required this.deleteNoteUseCase})
    : super(const NotesState());

  Future<void> loadNotes(String memoryBoxId) async {
    emit(state.copyWith(status: NotesStatus.loading));

    try {
      final notes = await getNotesUseCase(memoryBoxId);
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await deleteNoteUseCase(noteId: noteId);
      final filtered = state.notes.where((note) => note.id != noteId).toList();
      emit(state.copyWith(notes: filtered));
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
