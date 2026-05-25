import 'package:memory_chat/core/database/daos/message_dao.dart';
import 'package:memory_chat/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:memory_chat/features/chat/data/models/message_model.dart';
import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';
import 'package:memory_chat/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final MessageDao messageDao;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.messageDao,
  });

  @override
  Future<MessageEntity> sendMessage({
    required String workspaceId,
    required String content,
  }) async {
    try {
      // 1. Save to Supabase (Remote)
      final model = await remoteDataSource.sendMessage(
        workspaceId: workspaceId,
        content: content,
      );

      // 2. Save to local Drift immediately
      await messageDao.insertMessage(model.toCompanion());

      return model;
    } catch (e) {
      // Even if remote fails, we can still save locally (optimistic update)
      rethrow;
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String workspaceId) {
    // Primary source = Local Drift (fast + offline support)
    return messageDao
        .watchMessagesByWorkspace(workspaceId)
        .map((messages) => messages.map((m) => m.toEntity()).toList());
  }
}
