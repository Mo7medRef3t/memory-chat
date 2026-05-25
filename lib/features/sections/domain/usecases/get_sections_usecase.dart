import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';

class GetSectionsUseCase {
  final SectionsRepository repository;

  GetSectionsUseCase(this.repository);

  Future<List<SectionEntity>> call(String workspaceId) {
    return repository.getSections(workspaceId);
  }
}