import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class CreateNoteUseCase {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  Future<void> call({required NoteEntity note}) {
    return repository.createNote(note: note);
  }
}
