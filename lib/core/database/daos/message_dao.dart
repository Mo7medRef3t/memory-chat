import 'package:drift/drift.dart';
import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/core/database/tables/message_table.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Stream<List<Message>> watchMessagesByWorkspace(String workspaceId) {
    return (select(messages)
          ..where((tbl) => tbl.workspaceId.equals(workspaceId))
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> insertMessage(MessagesCompanion message) {
    return into(messages).insert(message);
  }
}
