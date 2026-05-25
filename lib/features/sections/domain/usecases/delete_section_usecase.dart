import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';

class DeleteSectionUseCase {
  final SectionsRepository repository;

  DeleteSectionUseCase(this.repository);

  Future<void> call({required String sectionId}) {
    return repository.deleteSection(sectionId: sectionId);
  }
}
