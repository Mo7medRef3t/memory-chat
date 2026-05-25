import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String workspaceId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? senderName;

  const MessageEntity({
    required this.id,
    required this.workspaceId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.senderName,
  });

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    senderId,
    content,
    createdAt,
    updatedAt,
    senderName,
  ];
}
