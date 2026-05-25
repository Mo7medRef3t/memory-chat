import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<void> call({
    required String noteId,
    required String title,
    required String content,
  }) {
    return repository.updateNote(
      noteId: noteId,
      title: title,
      content: content,
    );
  }
}
