import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class DeleteMemoryBoxUseCase {
  final MemoryBoxesRepository repository;

  DeleteMemoryBoxUseCase(this.repository);

  Future<void> call({required String memoryBoxId}) {
    return repository.deleteMemoryBox(memoryBoxId: memoryBoxId);
  }
}
