import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memory_chat/app/di/injection_container.dart';
import 'package:memory_chat/app/router/route_names.dart';
import 'package:memory_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:memory_chat/features/chat/presentation/cubit/chat_state.dart';
import 'package:memory_chat/features/chat/presentation/pages/message_bubble.dart';
import 'package:memory_chat/shared/widgets/loading_indicator.dart';

class ChatPage extends StatefulWidget {
  final String workspaceId;
  final String? workspaceName;

  const ChatPage({super.key, required this.workspaceId, this.workspaceName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = sl<ChatCubit>();
    _chatCubit.watchMessages(widget.workspaceId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _chatCubit.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      _chatCubit.sendMessage(
        workspaceId: widget.workspaceId,
        content: _controller.text,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.workspaceName ?? 'Chat'),
          leading: BackButton(onPressed: () => context.goNamed(RouteNames.workspaceList)),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.status == ChatStatus.loading) {
                    return const LoadingIndicator();
                  }
                  if (state.status == ChatStatus.failure) {
                    return Center(child: Text(state.errorMessage ?? 'Error'));
                  }

                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Start chatting!'),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: state.messages[index]);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
