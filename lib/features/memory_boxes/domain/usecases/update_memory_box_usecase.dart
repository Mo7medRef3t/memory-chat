import 'package:memory_chat/features/memory_boxes/domain/repositories/memory_boxes_repository.dart';

class UpdateMemoryBoxUseCase {
  final MemoryBoxesRepository repository;

  UpdateMemoryBoxUseCase(this.repository);

  Future<void> call({
    required String memoryBoxId,
    required String title,
    String? description,
  }) {
    return repository.updateMemoryBox(
      memoryBoxId: memoryBoxId,
      title: title,
      description: description,
    );
  }
}
