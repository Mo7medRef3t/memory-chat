import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';

abstract class MemoryBoxesRepository {
  Future<List<MemoryBoxEntity>> getMemoryBoxes({
    required String workspaceId,
    String? sectionId,
  });

  Future<void> createMemoryBox({required MemoryBoxEntity memoryBox});

  Future<void> updateMemoryBox({
    required String memoryBoxId,
    required String title,
    String? description,
  });

  Future<void> deleteMemoryBox({required String memoryBoxId});

  Future<void> moveMemoryBox({
    required String memoryBoxId,
    required String workspaceId,
    String? newSectionId,
  });
}
