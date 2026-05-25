import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/tables/section_table.dart';

part 'section_dao.g.dart';

@DriftAccessor(tables: [Sections])
class SectionDao extends DatabaseAccessor<AppDatabase> with _$SectionDaoMixin {
  SectionDao(super.db);

  Stream<List<Section>> watchSectionsByWorkspace(String workspaceId) {
    return (select(sections)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId))
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }
}
