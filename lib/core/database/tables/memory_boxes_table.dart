import 'package:drift/drift.dart';

@DataClassName('MemoryBoxRow')
class MemoryBoxes extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()(); // Always present
  TextColumn get sectionId => text().nullable()(); // Optional
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
