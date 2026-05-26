import 'package:memory_chat/features/memory_boxes/data/datasources/memory_boxes_remote_data_source.dart';
import 'package:memory_chat/features/memory_boxes/data/models/memory_box_model.dart';
import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class MemoryBoxesRepositoryImpl implements MemoryBoxesRepository {
  final MemoryBoxesRemoteDataSource remoteDataSource;

  MemoryBoxesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MemoryBoxEntity>> getMemoryBoxes({
    required String workspaceId,
    String? sectionId,
  }) {
    return remoteDataSource.getMemoryBoxes(
      workspaceId: workspaceId,
      sectionId: sectionId,
    );
  }

  @override
  Future<void> createMemoryBox({required MemoryBoxEntity memoryBox}) async {
    final model = MemoryBoxModel(
      id: memoryBox.id,
      workspaceId: memoryBox.workspaceId,
      sectionId: memoryBox.sectionId,
      title: memoryBox.title,
      description: memoryBox.description,
      createdAt: memoryBox.createdAt,
      updatedAt: memoryBox.updatedAt,
    );

    await remoteDataSource.createMemoryBox(model);
  }

  @override
  Future<void> updateMemoryBox({
    required String memoryBoxId,
    required String title,
    String? description,
  }) {
    return remoteDataSource.updateMemoryBox(
      memoryBoxId: memoryBoxId,
      title: title,
      description: description,
    );
  }

  @override
  Future<void> deleteMemoryBox({required String memoryBoxId}) {
    return remoteDataSource.deleteMemoryBox(memoryBoxId);
  }

  @override
  Future<void> moveMemoryBox({
    required String memoryBoxId,
    required String workspaceId,
    String? newSectionId,
  }) {
    return remoteDataSource.moveMemoryBox(
      memoryBoxId: memoryBoxId,
      workspaceId: workspaceId,
      newSectionId: newSectionId,
    );
  }
}
