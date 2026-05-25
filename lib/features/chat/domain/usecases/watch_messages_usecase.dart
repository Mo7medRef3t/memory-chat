import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';
import 'package:memory_chat/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String workspaceId) {
    return repository.watchMessages(workspaceId);
  }
}
