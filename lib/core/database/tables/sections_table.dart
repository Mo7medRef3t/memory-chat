import 'package:drift/drift.dart';

@DataClassName('SectionRow')
class Sections extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
