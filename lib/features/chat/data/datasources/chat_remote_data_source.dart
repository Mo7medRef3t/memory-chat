import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memory_chat/core/utils/id_generator.dart';
import 'package:memory_chat/features/chat/data/models/message_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient client;
  final IdGenerator idGenerator;

  ChatRemoteDataSource(this.client, this.idGenerator);

  Future<MessageModel> sendMessage({
    required String workspaceId,
    required String content,
  }) async {
    final user = client.auth.currentUser!;
    final messageId = idGenerator.generate();

    final response = await client
        .from('messages')
        .insert({
          'id': messageId,
          'workspace_id': workspaceId,
          'sender_id': user.id,
          'content': content.trim(),
        })
        .select()
        .single();

    return MessageModel.fromJson(response);
  }

  Stream<List<MessageModel>> watchMessages(String workspaceId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('workspace_id', workspaceId)
        .order('created_at', ascending: true)
        .map(
          (data) => data.map((json) => MessageModel.fromJson(json)).toList(),
        );
  }
}
