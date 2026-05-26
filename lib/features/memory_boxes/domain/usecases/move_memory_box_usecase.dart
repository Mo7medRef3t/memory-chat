import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class MoveMemoryBoxUseCase {
  final MemoryBoxesRepository repository;
  MoveMemoryBoxUseCase(this.repository);

  Future<void> call({
    required String memoryBoxId,
    required String workspaceId,
    String? newSectionId,
  }) {
    return repository.moveMemoryBox(
      memoryBoxId: memoryBoxId,
      workspaceId: workspaceId,
      newSectionId: newSectionId,
    );
  }
}
