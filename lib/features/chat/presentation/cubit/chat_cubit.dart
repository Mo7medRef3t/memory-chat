import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_chat/features/chat/domain/entities/message_entity.dart';
import 'package:memory_chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:memory_chat/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:memory_chat/features/chat/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final WatchMessagesUseCase watchMessagesUseCase;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  ChatCubit({
    required this.sendMessageUseCase,
    required this.watchMessagesUseCase,
  }) : super(const ChatState());

  void watchMessages(String workspaceId) {
    emit(state.copyWith(status: ChatStatus.loading));
    _messagesSubscription?.cancel();

    _messagesSubscription = watchMessagesUseCase(workspaceId).listen(
      (messages) {
        emit(state.copyWith(status: ChatStatus.success, messages: messages));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ChatStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> sendMessage({
    required String workspaceId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      await sendMessageUseCase(
        workspaceId: workspaceId,
        content: content.trim(),
      );
      // The stream will update automatically
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
