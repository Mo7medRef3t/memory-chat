import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/tables/workspace_table.dart';

part 'workspace_dao.g.dart';

@DriftAccessor(tables: [Workspaces])
class WorkspaceDao extends DatabaseAccessor<AppDatabase>
    with _$WorkspaceDaoMixin {
  WorkspaceDao(super.db);

  Stream<List<Workspace>> watchUserWorkspaces(String userId) {
    return (select(workspaces)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }
}
