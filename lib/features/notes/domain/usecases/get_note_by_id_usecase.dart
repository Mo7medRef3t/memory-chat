import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class GetNoteByIdUseCase {
  final NotesRepository repository;

  GetNoteByIdUseCase(this.repository);

  Future<NoteEntity?> call(String noteId) {
    return repository.getNoteById(noteId);
  }
}
