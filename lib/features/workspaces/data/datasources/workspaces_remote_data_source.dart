import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memory_chat/features/workspaces/data/models/workspace_model.dart';

class WorkspacesRemoteDataSource {
  final SupabaseClient client;

  WorkspacesRemoteDataSource(this.client);

  Future<List<WorkspaceModel>> getUserWorkspaces(String userId) async {
    final response = await client
        .from('workspaces')
        .select()
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => WorkspaceModel.fromJson(json))
        .toList();
  }

  Future<void> createWorkspace({
    required WorkspaceModel workspace,
    required String membershipId,
    required String currentUserId,
  }) async {
    await client.from('workspaces').insert(workspace.toInsertJson());

    await client.from('workspace_members').insert({
      'id': membershipId,
      'workspace_id': workspace.id,
      'user_id': currentUserId,
      'role': 'owner',
      'joined_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> updateWorkspace({
    required String workspaceId,
    required String name,
    String? description,
  }) async {
    await client
        .from('workspaces')
        .update({
          'name': name.trim(),
          'description': description?.trim().isEmpty == true
              ? null
              : description?.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', workspaceId);
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    await client.from('workspaces').delete().eq('id', workspaceId);
  }
}
