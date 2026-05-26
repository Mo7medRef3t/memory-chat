// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_boxes_dao.dart';

// ignore_for_file: type=lint
mixin _$MemoryBoxesDaoMixin on DatabaseAccessor<AppDatabase> {
  $MemoryBoxesTable get memoryBoxes => attachedDatabase.memoryBoxes;
  MemoryBoxesDaoManager get managers => MemoryBoxesDaoManager(this);
}

class MemoryBoxesDaoManager {
  final _$MemoryBoxesDaoMixin _db;
  MemoryBoxesDaoManager(this._db);
  $$MemoryBoxesTableTableManager get memoryBoxes =>
      $$MemoryBoxesTableTableManager(_db.attachedDatabase, _db.memoryBoxes);
}
