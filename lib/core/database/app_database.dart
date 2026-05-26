import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/workspaces_table.dart';
import 'tables/sections_table.dart';
import 'tables/memory_boxes_table.dart';
import 'tables/notes_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Workspaces, Sections, MemoryBoxes, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing only
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
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
