import 'package:memory_chat/features/memory_boxes/domain/entities/memory_box_entity.dart';
import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class GetMemoryBoxesUseCase {
  final MemoryBoxesRepository repository;

  GetMemoryBoxesUseCase(this.repository);

  Future<List<MemoryBoxEntity>> call(String sectionId) {
    return repository.getMemoryBoxes(sectionId);
  }
}
