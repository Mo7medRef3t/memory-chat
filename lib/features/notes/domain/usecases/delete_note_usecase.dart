import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class DeleteNoteUseCase {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<void> call({required String noteId}) {
    return repository.deleteNote(noteId: noteId);
  }
}
