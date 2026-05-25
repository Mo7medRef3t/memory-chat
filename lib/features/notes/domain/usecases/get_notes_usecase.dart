import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class GetNotesUseCase {
  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  Future<List<NoteEntity>> call(String memoryBoxId) {
    return repository.getNotes(memoryBoxId);
  }
}
