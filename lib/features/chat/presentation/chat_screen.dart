import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/models/chat_message.dart';
import 'chat_cubit.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.coachId,
    this.sessionId,
  });

  final String coachId;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScopeProvider.of(context);

    return BlocProvider(
      create: (_) => ChatCubit(
        chatRepository: scope.chatRepository,
        coachRepository: scope.coachRepository,
      )..initialize(
          coachId: coachId,
          sessionId: sessionId,
        ),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final prompt = _controller.text;
    if (prompt.trim().isEmpty) {
      return;
    }
    _controller.clear();
    context.read<ChatCubit>().sendMessage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) {
            return;
          }
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        });
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: state.status == ChatStatus.ready
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.coachSpecialty ?? 'Coach Chat'),
                      Text(
                        state.coachName ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                : const Text('Coach Chat'),
          ),
          body: switch (state.status) {
            ChatStatus.initial || ChatStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            ChatStatus.failure => Center(
                child: Text(state.errorMessage ?? 'Chat could not load.'),
              ),
            ChatStatus.ready => _ChatBody(
                state: state,
                controller: _controller,
                scrollController: _scrollController,
                onSubmit: _submit,
              ),
          },
        );
      },
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.state,
    required this.controller,
    required this.scrollController,
    required this.onSubmit,
  });

  final ChatState state;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final messages = state.session?.messages ?? const <ChatMessage>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: messages.length + (state.streamingReply.isNotEmpty ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return _MessageBubble(
                    isUser: false,
                    text: state.streamingReply,
                    timestamp: DateTime.now(),
                    isStreaming: true,
                  );
                }

                final message = messages[index];
                return _MessageBubble(
                  isUser: message.author == MessageAuthor.user,
                  text: message.text,
                  timestamp: message.createdAt,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
                  decoration: const InputDecoration(
                    hintText: 'Ask about nutrition, mobility, workouts, or recovery...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: state.isSending ? null : onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(56, 56),
                ),
                child: state.isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.isStreaming = false,
  });

  final bool isUser;
  final String text;
  final DateTime timestamp;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isUser ? Theme.of(context).colorScheme.primary : Colors.white;
    final textColor =
        isUser ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isUser
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(color: textColor, height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  isStreaming
                      ? 'Typing...'
                      : DateFormat('HH:mm').format(timestamp),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor.withValues(alpha: 0.72),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
