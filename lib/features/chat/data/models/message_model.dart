import 'package:memory_chat/core/database/app_database.dart';
import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';
import 'package:drift/drift.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.workspaceId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.updatedAt,
    super.deletedAt,
    super.senderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      senderName: json['sender_name'] as String?,
    );
  }
}

// Extension to convert to Drift Companion
extension MessageModelX on MessageModel {
  MessagesCompanion toCompanion() {
    return MessagesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      senderId: Value(senderId),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
    );
  }
}

// Extension to convert Drift row to Entity
extension MessageX on Message {
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      workspaceId: workspaceId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      senderName: null, // Will be populated from join if needed
    );
  }
}
