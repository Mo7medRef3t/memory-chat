import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class CreateMemoryBoxUseCase {
  final MemoryBoxesRepository repository;

  CreateMemoryBoxUseCase(this.repository);

  Future<void> call({required MemoryBoxEntity memoryBox}) {
    return repository.createMemoryBox(memoryBox: memoryBox);
  }
}
