// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_box_dao.dart';

// ignore_for_file: type=lint
mixin _$MemoryBoxDaoMixin on DatabaseAccessor<AppDatabase> {
  $MemoryBoxesTable get memoryBoxes => attachedDatabase.memoryBoxes;
  MemoryBoxDaoManager get managers => MemoryBoxDaoManager(this);
}

class MemoryBoxDaoManager {
  final _$MemoryBoxDaoMixin _db;
  MemoryBoxDaoManager(this._db);
  $$MemoryBoxesTableTableManager get memoryBoxes =>
      $$MemoryBoxesTableTableManager(_db.attachedDatabase, _db.memoryBoxes);
}
