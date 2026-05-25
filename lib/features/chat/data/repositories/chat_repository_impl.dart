import 'package:memory_chat/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';
import 'package:memory_chat/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<MessageEntity> sendMessage({
    required String workspaceId,
    required String content,
  }) async {
    final model = await remoteDataSource.sendMessage(
      workspaceId: workspaceId,
      content: content,
    );
    return model;
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String workspaceId) {
    return remoteDataSource.watchMessages(workspaceId);
  }
}
