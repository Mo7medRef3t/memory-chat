import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';

abstract class SectionsRepository {
  Future<List<SectionEntity>> getSections(String workspaceId);

  Future<void> createSection({required SectionEntity section});

  Future<void> renameSection({
    required String sectionId,
    required String newTitle,
  });

  Future<void> deleteSection({required String sectionId});
}
