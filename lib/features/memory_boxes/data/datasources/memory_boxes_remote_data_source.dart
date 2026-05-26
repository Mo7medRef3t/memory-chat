import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memory_chat/features/memory_boxes/data/models/memory_box_model.dart';

class MemoryBoxesRemoteDataSource {
  final SupabaseClient client;

  MemoryBoxesRemoteDataSource(this.client);

  Future<List<MemoryBoxModel>> getMemoryBoxes({
    required String workspaceId,
    String? sectionId,
  }) async {
    var query = client.from('memory_boxes').select();

    if (sectionId != null) {
      query = query.eq('section_id', sectionId);
    } else {
      query = query
          .eq('workspace_id', workspaceId)
          .isFilter('section_id', null);
    }

    final response = await query.order('created_at', ascending: true);

    return (response as List)
        .map((json) => MemoryBoxModel.fromJson(json))
        .toList();
  }

  Future<void> createMemoryBox(MemoryBoxModel memoryBox) async {
    await client.from('memory_boxes').insert(memoryBox.toInsertJson());
  }

  Future<void> updateMemoryBox({
    required String memoryBoxId,
    required String title,
    String? description,
  }) async {
    await client
        .from('memory_boxes')
        .update({
          'title': title.trim(),
          'description': description?.trim().isEmpty == true
              ? null
              : description?.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', memoryBoxId);
  }

  Future<void> deleteMemoryBox(String memoryBoxId) async {
    await client.from('memory_boxes').delete().eq('id', memoryBoxId);
  }

  Future<void> moveMemoryBox({
    required String memoryBoxId,
    required String workspaceId,
    String? newSectionId,
  }) async {
    await client
        .from('memory_boxes')
        .update({
          'workspace_id': workspaceId,
          'section_id': newSectionId,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', memoryBoxId);
  }
}
