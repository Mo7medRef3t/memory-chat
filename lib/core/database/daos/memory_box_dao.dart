import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/tables/memory_box_table.dart';

part 'memory_box_dao.g.dart';

@DriftAccessor(tables: [MemoryBoxes])
class MemoryBoxDao extends DatabaseAccessor<AppDatabase>
    with _$MemoryBoxDaoMixin {
  MemoryBoxDao(super.db);

  Stream<List<MemoryBoxe>> watchMemoryBoxesBySection(String sectionId) {
    return (select(memoryBoxes)
          ..where((tbl) => tbl.sectionId.equals(sectionId))
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }
}
