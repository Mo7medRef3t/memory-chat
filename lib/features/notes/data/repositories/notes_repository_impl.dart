import 'package:memory_chat/features/notes/data/datasources/notes_remote_data_source.dart';
import 'package:memory_chat/features/notes/data/models/note_model.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NoteEntity>> getNotes(String memoryBoxId) {
    return remoteDataSource.getNotes(memoryBoxId);
  }

  @override
  Future<NoteEntity?> getNoteById(String noteId) {
    return remoteDataSource.getNoteById(noteId);
  }

  @override
  Future<void> createNote({required NoteEntity note}) async {
    final model = NoteModel(
      id: note.id,
      memoryBoxId: note.memoryBoxId,
      authorId: note.authorId,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );

    await remoteDataSource.createNote(model);
  }

  @override
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    return remoteDataSource.updateNote(
      noteId: noteId,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteNote({required String noteId}) {
    return remoteDataSource.deleteNote(noteId);
  }
}
