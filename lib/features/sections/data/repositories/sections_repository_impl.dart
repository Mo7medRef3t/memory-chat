import 'package:memory_chat/features/sections/data/datasources/sections_remote_data_source.dart';
import 'package:memory_chat/features/sections/data/models/section_model.dart';
import 'package:memory_chat/features/sections/domain/entities/section_entity.dart';
import 'package:memory_chat/features/sections/domain/repositories/sections_repository.dart';

class SectionsRepositoryImpl implements SectionsRepository {
  final SectionsRemoteDataSource remoteDataSource;

  SectionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SectionEntity>> getSections(String workspaceId) {
    return remoteDataSource.getSections(workspaceId);
  }

  @override
  Future<void> createSection({required SectionEntity section}) async {
    final model = SectionModel(
      id: section.id,
      workspaceId: section.workspaceId,
      title: section.title,
      createdAt: section.createdAt,
      updatedAt: section.updatedAt,
    );

    await remoteDataSource.createSection(model);
  }

  @override
  Future<void> renameSection({
    required String sectionId,
    required String newTitle,
  }) {
    return remoteDataSource.renameSection(
      sectionId: sectionId,
      newTitle: newTitle,
    );
  }

  @override
  Future<void> deleteSection({required String sectionId}) {
    return remoteDataSource.deleteSection(sectionId);
  }
}
