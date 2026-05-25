import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memory_chat/features/sections/data/models/section_model.dart';

class SectionsRemoteDataSource {
  final SupabaseClient client;

  SectionsRemoteDataSource(this.client);

  Future<List<SectionModel>> getSections(String workspaceId) async {
    final response = await client
        .from('sections')
        .select()
        .eq('workspace_id', workspaceId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => SectionModel.fromJson(json))
        .toList();
  }

  Future<void> createSection(SectionModel section) async {
    await client.from('sections').insert(section.toInsertJson());
  }

  Future<void> renameSection({
    required String sectionId,
    required String newTitle,
  }) async {
    await client
        .from('sections')
        .update({
          'title': newTitle.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', sectionId);
  }

  Future<void> deleteSection(String sectionId) async {
    await client
        .from('sections')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', sectionId);
  }
}
