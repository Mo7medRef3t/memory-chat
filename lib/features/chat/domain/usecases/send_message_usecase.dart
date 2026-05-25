import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';
import 'package:memory_chat/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<MessageEntity> call({
    required String workspaceId,
    required String content,
  }) {
    return repository.sendMessage(workspaceId: workspaceId, content: content);
  }
}
