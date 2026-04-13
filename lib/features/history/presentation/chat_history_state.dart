part of 'chat_history_cubit.dart';

enum ChatHistoryStatus {
  initial,
  loading,
  success,
  failure,
}

class ChatHistoryState extends Equatable {
  const ChatHistoryState({
    this.status = ChatHistoryStatus.initial,
    this.sessions = const [],
    this.errorMessage,
  });

  final ChatHistoryStatus status;
  final List<ChatSession> sessions;
  final String? errorMessage;

  ChatHistoryState copyWith({
    ChatHistoryStatus? status,
    List<ChatSession>? sessions,
    String? errorMessage,
  }) {
    return ChatHistoryState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}
