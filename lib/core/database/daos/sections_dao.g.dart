// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sections_dao.dart';

// ignore_for_file: type=lint
mixin _$SectionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SectionsTable get sections => attachedDatabase.sections;
  SectionsDaoManager get managers => SectionsDaoManager(this);
}

class SectionsDaoManager {
  final _$SectionsDaoMixin _db;
  SectionsDaoManager(this._db);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
}
