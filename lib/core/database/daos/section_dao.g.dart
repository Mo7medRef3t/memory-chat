// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_dao.dart';

// ignore_for_file: type=lint
mixin _$SectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $SectionsTable get sections => attachedDatabase.sections;
  SectionDaoManager get managers => SectionDaoManager(this);
}

class SectionDaoManager {
  final _$SectionDaoMixin _db;
  SectionDaoManager(this._db);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
}
