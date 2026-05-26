import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/mappers/entity_mappers.dart';
import 'package:memory_chat/core/database/tables/sections_table.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';

part 'sections_dao.g.dart';

@DriftAccessor(tables: [Sections])
class SectionsDao extends DatabaseAccessor<AppDatabase>
    with _$SectionsDaoMixin {
  SectionsDao(super.db);

  Stream<List<SectionEntity>> watchSectionsByWorkspace(String workspaceId) {
    return (select(sections)
          ..where((t) => t.workspaceId.equals(workspaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .map((row) => row.toEntity())
        .watch();
  }

  Future<void> insertSection(SectionEntity entity) {
    return into(sections).insert(entity.toCompanion());
  }

  Future<void> updateSection(SectionEntity entity) {
    return (update(
      sections,
    )..where((t) => t.id.equals(entity.id))).write(entity.toCompanion());
  }

  Future<void> deleteSection(String id) {
    return (delete(sections)..where((t) => t.id.equals(id))).go();
  }

  Future<void> replaceAll(List<SectionEntity> entities) async {
    await batch((batch) {
      batch.deleteAll(sections);
      batch.insertAll(sections, entities.map((e) => e.toCompanion()).toList());
    });
  }
}
