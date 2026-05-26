import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/mappers/entity_mappers.dart';
import 'package:memory_chat/core/database/tables/notes_table.dart';
import 'package:memory_chat/features/notes/domain/entities/note_entity.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<NoteEntity>> watchByMemoryBox(String memoryBoxId) {
    return (select(notes)
          ..where((t) => t.memoryBoxId.equals(memoryBoxId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .map((row) => row.toEntity())
        .watch();
  }

  Stream<NoteEntity?> watchNoteById(String id) {
    return (select(notes)..where((t) => t.id.equals(id)))
        .map((row) => row.toEntity())
        .watchSingleOrNull();
  }

  Future<void> insertNote(NoteEntity entity) {
    return into(notes).insert(entity.toCompanion());
  }

  Future<void> updateNote(NoteEntity entity) {
    return (update(
      notes,
    )..where((t) => t.id.equals(entity.id))).write(entity.toCompanion());
  }

  Future<void> deleteNote(String id) {
    return (delete(notes)..where((t) => t.id.equals(id))).go();
  }

  Future<void> replaceAll(List<NoteEntity> entities) async {
    await batch((batch) {
      batch.deleteAll(notes);
      batch.insertAll(notes, entities.map((e) => e.toCompanion()).toList());
    });
  }
}
