import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/core/sync/powersync_service.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';
import 'package:memory_chat/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final PowerSyncService _powerSync;

  NotesRepositoryImpl() : _powerSync = sl<PowerSyncService>();

  NoteEntity _rowToEntity(Map<String, dynamic> row) {
    return NoteEntity(
      id: row['id'] as String,
      memoryBoxId: row['memory_box_id'] as String,
      authorId: row['author_id'] as String,
      title: row['title'] as String,
      content: row['content'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  @override
  Stream<List<NoteEntity>> getNotes(String memoryBoxId) {
    return _powerSync.database
        .watch(
          'SELECT * FROM notes WHERE memory_box_id = ? ORDER BY updated_at DESC',
          parameters: [memoryBoxId],
        )
        .map((results) {
          return results.map((row) => _rowToEntity(row)).toList();
        });
  }

  @override
  Future<NoteEntity?> getNoteById(String noteId) async {
    final results = await _powerSync.database.getAll(
      'SELECT * FROM notes WHERE id = ?',
      [noteId],
    );

    if (results.isEmpty) return null;
    return _rowToEntity(results.first);
  }

  @override
  Future<void> createNote({required NoteEntity note}) async {
    await _powerSync.database.execute(
      '''INSERT INTO notes (id, memory_box_id, author_id, title, content, created_at, updated_at) 
       VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        note.id,
        note.memoryBoxId,
        note.authorId,
        note.title,
        note.content,
        note.createdAt.toUtc().toIso8601String(),
        note.updatedAt.toUtc().toIso8601String(),
      ],
    );
  }

  @override
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final existingNote = await getNoteById(noteId);
    if (existingNote == null) {
      throw Exception('Note not found.');
    }

    final updatedNote = NoteEntity(
      id: existingNote.id,
      memoryBoxId: existingNote.memoryBoxId,
      authorId: existingNote.authorId,
      title: title,
      content: content,
      createdAt: existingNote.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );

    await _powerSync.database.execute(
      '''UPDATE notes 
         SET title = ?, content = ?, updated_at = ? 
         WHERE id = ?''',
      [
        updatedNote.title,
        updatedNote.content,
        updatedNote.updatedAt.toUtc().toIso8601String(),
        noteId,
      ],
    );
  }

  @override
  Future<void> deleteNote({required String noteId}) async {
    await _powerSync.database.execute('DELETE FROM notes WHERE id = ?', [
      noteId,
    ]);
  }
}
