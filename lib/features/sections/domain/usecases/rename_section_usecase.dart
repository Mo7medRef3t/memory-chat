import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';

class RenameSectionUseCase {
  final SectionsRepository repository;

  RenameSectionUseCase(this.repository);

  Future<void> call({required String sectionId, required String newTitle}) {
    return repository.renameSection(sectionId: sectionId, newTitle: newTitle);
  }
}
