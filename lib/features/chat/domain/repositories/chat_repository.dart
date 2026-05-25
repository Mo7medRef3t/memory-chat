import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<MessageEntity> sendMessage({
    required String workspaceId,
    required String content,
  });

  Stream<List<MessageEntity>> watchMessages(String workspaceId);
}
