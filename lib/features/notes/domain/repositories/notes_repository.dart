import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotes(String memoryBoxId);

  Future<NoteEntity?> getNoteById(String noteId);

  Future<void> createNote({required NoteEntity note});

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  });

  Future<void> deleteNote({required String noteId});
}
