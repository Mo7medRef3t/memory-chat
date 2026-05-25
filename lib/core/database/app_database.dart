import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/workspace_table.dart';
import 'tables/section_table.dart';
import 'tables/memory_box_table.dart';
import 'tables/note_table.dart';
import 'tables/message_table.dart';

import 'daos/workspace_dao.dart';
import 'daos/section_dao.dart';
import 'daos/memory_box_dao.dart';
import 'daos/note_dao.dart';
import 'daos/message_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Workspaces, Sections, MemoryBoxes, Notes, Messages],
  daos: [WorkspaceDao, SectionDao, MemoryBoxDao, NoteDao, MessageDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future schema migrations will go here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memory_chat.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
