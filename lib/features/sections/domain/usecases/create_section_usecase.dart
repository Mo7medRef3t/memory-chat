import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';

class CreateSectionUseCase {
  final SectionsRepository repository;

  CreateSectionUseCase(this.repository);

  Future<void> call({required SectionEntity section}) {
    return repository.createSection(section: section);
  }
}
