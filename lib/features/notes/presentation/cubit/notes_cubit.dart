import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:memory_chat/features/notes/domain/usecases/get_notes_usecase.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  StreamSubscription<List<NoteEntity>>? _subscription;

  NotesCubit({required this.getNotesUseCase, required this.deleteNoteUseCase})
    : super(const NotesState());

  void loadNotes(String memoryBoxId) {
    emit(state.copyWith(status: NotesStatus.loading));

    _subscription?.cancel();

    _subscription = getNotesUseCase(memoryBoxId).listen(
      (notes) {
        emit(state.copyWith(status: NotesStatus.success, notes: notes));
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: NotesStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      },
    );
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await deleteNoteUseCase(noteId: noteId);
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    super.close();
  }
}
