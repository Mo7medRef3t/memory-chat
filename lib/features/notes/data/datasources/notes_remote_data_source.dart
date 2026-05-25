import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memory_chat/features/notes/data/models/note_model.dart';

class NotesRemoteDataSource {
  final SupabaseClient client;

  NotesRemoteDataSource(this.client);

  Future<List<NoteModel>> getNotes(String memoryBoxId) async {
    final response = await client
        .from('notes')
        .select()
        .eq('memory_box_id', memoryBoxId)
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: false);

    return (response as List).map((json) => NoteModel.fromJson(json)).toList();
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    final response = await client
        .from('notes')
        .select()
        .eq('id', noteId)
        .maybeSingle();

    if (response == null) return null;
    return NoteModel.fromJson(response);
  }

  Future<void> createNote(NoteModel note) async {
    await client.from('notes').insert(note.toInsertJson());
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    await client
        .from('notes')
        .update({
          'title': title.trim(),
          'content': content,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', noteId);
  }

  Future<void> deleteNote(String noteId) async {
    await client
        .from('notes')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', noteId);
  }
}
